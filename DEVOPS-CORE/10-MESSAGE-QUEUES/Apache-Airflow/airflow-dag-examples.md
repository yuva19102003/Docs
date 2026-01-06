# Apache Airflow DAG Examples - Complete Guide

## Overview

Apache Airflow is a platform to programmatically author, schedule, and monitor workflows. This guide provides comprehensive DAG (Directed Acyclic Graph) examples for common data engineering and DevOps tasks.

## Table of Contents

1. [Basic DAG Examples](#basic-dag-examples)
2. [ETL Pipeline Examples](#etl-pipeline-examples)
3. [Data Processing Examples](#data-processing-examples)
4. [DevOps Automation Examples](#devops-automation-examples)
5. [Advanced Patterns](#advanced-patterns)

## Basic DAG Examples

### 1. Simple Hello World DAG

```python
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator

# Default arguments for all tasks
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email': ['admin@example.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Define the DAG
dag = DAG(
    'hello_world_dag',
    default_args=default_args,
    description='A simple hello world DAG',
    schedule_interval=timedelta(days=1),
    catchup=False,
    tags=['example', 'tutorial'],
)

def print_hello():
    """Simple Python function"""
    print("Hello from Airflow!")
    return "Hello World"

def print_date():
    """Print current date"""
    print(f"Current date: {datetime.now()}")
    return datetime.now()

# Define tasks
task_hello = PythonOperator(
    task_id='print_hello',
    python_callable=print_hello,
    dag=dag,
)

task_date = PythonOperator(
    task_id='print_date',
    python_callable=print_date,
    dag=dag,
)

task_bash = BashOperator(
    task_id='bash_command',
    bash_command='echo "Running Bash command"',
    dag=dag,
)

# Set task dependencies
task_hello >> task_date >> task_bash
```

### 2. TaskFlow API Example (Modern Approach)

```python
from datetime import datetime, timedelta
from airflow.decorators import dag, task

default_args = {
    'owner': 'airflow',
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

@dag(
    dag_id='taskflow_example',
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule_interval='@daily',
    catchup=False,
    tags=['taskflow', 'example'],
)
def taskflow_example_dag():
    """
    Example DAG using TaskFlow API
    """
    
    @task()
    def extract():
        """Extract data"""
        data = {
            'users': ['Alice', 'Bob', 'Charlie'],
            'scores': [95, 87, 92]
        }
        return data
    
    @task()
    def transform(data: dict):
        """Transform data"""
        transformed = {
            'users': data['users'],
            'scores': [score * 1.1 for score in data['scores']],  # 10% bonus
            'grades': ['A' if score >= 90 else 'B' for score in data['scores']]
        }
        return transformed
    
    @task()
    def load(data: dict):
        """Load data"""
        print("Loading data:")
        for user, score, grade in zip(data['users'], data['scores'], data['grades']):
            print(f"{user}: {score:.2f} (Grade: {grade})")
        return "Data loaded successfully"
    
    # Define task flow
    extracted_data = extract()
    transformed_data = transform(extracted_data)
    load(transformed_data)

# Instantiate the DAG
dag_instance = taskflow_example_dag()
```

## ETL Pipeline Examples

### 3. Database ETL Pipeline

```python
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
import pandas as pd

default_args = {
    'owner': 'data_team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': True,
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'database_etl_pipeline',
    default_args=default_args,
    description='ETL pipeline from source to target database',
    schedule_interval='0 2 * * *',  # Run at 2 AM daily
    catchup=False,
    tags=['etl', 'database'],
)

def extract_from_source(**context):
    """Extract data from source database"""
    source_hook = PostgresHook(postgres_conn_id='source_db')
    
    sql = """
        SELECT 
            user_id,
            username,
            email,
            created_at,
            last_login
        FROM users
        WHERE DATE(last_login) = CURRENT_DATE - INTERVAL '1 day'
    """
    
    df = source_hook.get_pandas_df(sql)
    
    # Push data to XCom
    context['task_instance'].xcom_push(key='extracted_data', value=df.to_json())
    
    print(f"Extracted {len(df)} records")
    return len(df)

def transform_data(**context):
    """Transform extracted data"""
    # Pull data from XCom
    ti = context['task_instance']
    json_data = ti.xcom_pull(key='extracted_data', task_ids='extract_data')
    
    df = pd.read_json(json_data)
    
    # Data transformations
    df['username'] = df['username'].str.lower()
    df['email'] = df['email'].str.lower()
    df['full_name'] = df['username'].str.title()
    df['days_since_login'] = (datetime.now() - pd.to_datetime(df['last_login'])).dt.days
    
    # Data quality checks
    df = df.dropna(subset=['email'])
    df = df[df['email'].str.contains('@')]
    
    # Push transformed data
    ti.xcom_push(key='transformed_data', value=df.to_json())
    
    print(f"Transformed {len(df)} records")
    return len(df)

def load_to_target(**context):
    """Load data to target database"""
    ti = context['task_instance']
    json_data = ti.xcom_pull(key='transformed_data', task_ids='transform_data')
    
    df = pd.read_json(json_data)
    
    target_hook = PostgresHook(postgres_conn_id='target_db')
    engine = target_hook.get_sqlalchemy_engine()
    
    # Load data
    df.to_sql(
        'user_analytics',
        engine,
        if_exists='append',
        index=False,
        method='multi',
        chunksize=1000
    )
    
    print(f"Loaded {len(df)} records to target database")
    return len(df)

# Create target table if not exists
create_table = PostgresOperator(
    task_id='create_target_table',
    postgres_conn_id='target_db',
    sql="""
        CREATE TABLE IF NOT EXISTS user_analytics (
            user_id INTEGER,
            username VARCHAR(255),
            email VARCHAR(255),
            full_name VARCHAR(255),
            created_at TIMESTAMP,
            last_login TIMESTAMP,
            days_since_login INTEGER,
            processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    """,
    dag=dag,
)

extract_task = PythonOperator(
    task_id='extract_data',
    python_callable=extract_from_source,
    provide_context=True,
    dag=dag,
)

transform_task = PythonOperator(
    task_id='transform_data',
    python_callable=transform_data,
    provide_context=True,
    dag=dag,
)

load_task = PythonOperator(
    task_id='load_data',
    python_callable=load_to_target,
    provide_context=True,
    dag=dag,
)

# Data quality check
quality_check = PostgresOperator(
    task_id='data_quality_check',
    postgres_conn_id='target_db',
    sql="""
        SELECT COUNT(*) as record_count
        FROM user_analytics
        WHERE DATE(processed_at) = CURRENT_DATE;
    """,
    dag=dag,
)

# Set dependencies
create_table >> extract_task >> transform_task >> load_task >> quality_check
```

### 4. API to Database ETL

```python
from datetime import datetime, timedelta
from airflow.decorators import dag, task
import requests
import pandas as pd
from airflow.providers.postgres.hooks.postgres import PostgresHook

default_args = {
    'owner': 'data_team',
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
}

@dag(
    dag_id='api_to_database_etl',
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule_interval='@hourly',
    catchup=False,
    tags=['etl', 'api'],
)
def api_to_database_pipeline():
    """
    Extract data from REST API and load to database
    """
    
    @task()
    def extract_from_api():
        """Fetch data from REST API"""
        api_url = "https://api.example.com/v1/data"
        headers = {"Authorization": "Bearer YOUR_API_TOKEN"}
        
        response = requests.get(api_url, headers=headers)
        response.raise_for_status()
        
        data = response.json()
        print(f"Extracted {len(data['results'])} records from API")
        
        return data['results']
    
    @task()
    def transform_api_data(raw_data: list):
        """Transform API data"""
        df = pd.DataFrame(raw_data)
        
        # Data transformations
        df['timestamp'] = pd.to_datetime(df['timestamp'])
        df['value'] = pd.to_numeric(df['value'], errors='coerce')
        
        # Remove duplicates
        df = df.drop_duplicates(subset=['id'])
        
        # Filter invalid records
        df = df[df['value'].notna()]
        
        print(f"Transformed {len(df)} valid records")
        
        return df.to_dict('records')
    
    @task()
    def load_to_database(data: list):
        """Load data to PostgreSQL"""
        df = pd.DataFrame(data)
        
        hook = PostgresHook(postgres_conn_id='postgres_default')
        engine = hook.get_sqlalchemy_engine()
        
        df.to_sql(
            'api_data',
            engine,
            if_exists='append',
            index=False
        )
        
        print(f"Loaded {len(df)} records to database")
        return len(df)
    
    # Define pipeline
    raw_data = extract_from_api()
    transformed_data = transform_api_data(raw_data)
    load_to_database(transformed_data)

# Instantiate DAG
dag_instance = api_to_database_pipeline()
```

## Data Processing Examples

### 5. File Processing Pipeline

```python
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor
import pandas as pd
import io

default_args = {
    'owner': 'data_team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'file_processing_pipeline',
    default_args=default_args,
    description='Process CSV files from S3',
    schedule_interval='*/30 * * * *',  # Every 30 minutes
    catchup=False,
    tags=['file-processing', 's3'],
)

def process_csv_file(**context):
    """Process CSV file from S3"""
    s3_hook = S3Hook(aws_conn_id='aws_default')
    
    bucket_name = 'my-data-bucket'
    file_key = f"raw/data_{context['ds']}.csv"
    
    # Read file from S3
    file_content = s3_hook.read_key(
        key=file_key,
        bucket_name=bucket_name
    )
    
    # Process data
    df = pd.read_csv(io.StringIO(file_content))
    
    # Data processing
    df['processed_at'] = datetime.now()
    df['total'] = df['quantity'] * df['price']
    
    # Aggregate data
    summary = df.groupby('category').agg({
        'total': 'sum',
        'quantity': 'sum'
    }).reset_index()
    
    # Save processed file back to S3
    csv_buffer = io.StringIO()
    summary.to_csv(csv_buffer, index=False)
    
    processed_key = f"processed/summary_{context['ds']}.csv"
    s3_hook.load_string(
        string_data=csv_buffer.getvalue(),
        key=processed_key,
        bucket_name=bucket_name,
        replace=True
    )
    
    print(f"Processed {len(df)} records, created summary with {len(summary)} categories")
    return processed_key

# Wait for file to arrive
wait_for_file = S3KeySensor(
    task_id='wait_for_file',
    bucket_name='my-data-bucket',
    bucket_key='raw/data_{{ ds }}.csv',
    aws_conn_id='aws_default',
    timeout=600,
    poke_interval=60,
    dag=dag,
)

process_file = PythonOperator(
    task_id='process_file',
    python_callable=process_csv_file,
    provide_context=True,
    dag=dag,
)

wait_for_file >> process_file
```

## DevOps Automation Examples

### 6. Backup Automation DAG

```python
from datetime import datetime, timedelta
from airflow.decorators import dag, task
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
import subprocess
import os

default_args = {
    'owner': 'devops',
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

@dag(
    dag_id='database_backup_automation',
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule_interval='0 3 * * *',  # Daily at 3 AM
    catchup=False,
    tags=['backup', 'devops'],
)
def database_backup_dag():
    """
    Automated database backup to S3
    """
    
    @task()
    def create_database_backup():
        """Create PostgreSQL backup"""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_file = f"/tmp/backup_{timestamp}.sql"
        
        # Create backup using pg_dump
        cmd = [
            'pg_dump',
            '-h', 'localhost',
            '-U', 'postgres',
            '-d', 'production_db',
            '-F', 'c',  # Custom format
            '-f', backup_file
        ]
        
        subprocess.run(cmd, check=True)
        
        print(f"Backup created: {backup_file}")
        return backup_file
    
    @task()
    def compress_backup(backup_file: str):
        """Compress backup file"""
        compressed_file = f"{backup_file}.gz"
        
        subprocess.run(['gzip', backup_file], check=True)
        
        print(f"Backup compressed: {compressed_file}")
        return compressed_file
    
    @task()
    def upload_to_s3(compressed_file: str):
        """Upload backup to S3"""
        s3_hook = S3Hook(aws_conn_id='aws_default')
        
        bucket_name = 'database-backups'
        s3_key = f"backups/{os.path.basename(compressed_file)}"
        
        s3_hook.load_file(
            filename=compressed_file,
            key=s3_key,
            bucket_name=bucket_name,
            replace=True
        )
        
        print(f"Backup uploaded to s3://{bucket_name}/{s3_key}")
        return s3_key
    
    @task()
    def cleanup_old_backups():
        """Remove backups older than 30 days"""
        s3_hook = S3Hook(aws_conn_id='aws_default')
        bucket_name = 'database-backups'
        
        # List all backups
        keys = s3_hook.list_keys(bucket_name=bucket_name, prefix='backups/')
        
        cutoff_date = datetime.now() - timedelta(days=30)
        deleted_count = 0
        
        for key in keys:
            # Get object metadata
            obj = s3_hook.get_key(key, bucket_name)
            if obj.last_modified.replace(tzinfo=None) < cutoff_date:
                s3_hook.delete_objects(bucket=bucket_name, keys=key)
                deleted_count += 1
        
        print(f"Deleted {deleted_count} old backups")
        return deleted_count
    
    @task()
    def cleanup_local_files(compressed_file: str):
        """Remove local backup files"""
        if os.path.exists(compressed_file):
            os.remove(compressed_file)
            print(f"Removed local file: {compressed_file}")
    
    # Define pipeline
    backup = create_database_backup()
    compressed = compress_backup(backup)
    uploaded = upload_to_s3(compressed)
    cleanup_old_backups()
    cleanup_local_files(compressed)

# Instantiate DAG
dag_instance = database_backup_dag()
```

### 7. Infrastructure Monitoring DAG

```python
from datetime import datetime, timedelta
from airflow.decorators import dag, task
from airflow.providers.http.hooks.http import HttpHook
import requests

default_args = {
    'owner': 'devops',
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
}

@dag(
    dag_id='infrastructure_monitoring',
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule_interval='*/5 * * * *',  # Every 5 minutes
    catchup=False,
    tags=['monitoring', 'devops'],
)
def infrastructure_monitoring_dag():
    """
    Monitor infrastructure health
    """
    
    @task()
    def check_website_health():
        """Check website availability"""
        websites = [
            'https://example.com',
            'https://api.example.com',
            'https://admin.example.com'
        ]
        
        results = []
        for url in websites:
            try:
                response = requests.get(url, timeout=10)
                status = 'UP' if response.status_code == 200 else 'DOWN'
                results.append({
                    'url': url,
                    'status': status,
                    'response_time': response.elapsed.total_seconds()
                })
            except Exception as e:
                results.append({
                    'url': url,
                    'status': 'ERROR',
                    'error': str(e)
                })
        
        return results
    
    @task()
    def check_api_endpoints():
        """Check API endpoint health"""
        endpoints = [
            '/api/v1/health',
            '/api/v1/status',
            '/api/v1/metrics'
        ]
        
        base_url = 'https://api.example.com'
        results = []
        
        for endpoint in endpoints:
            try:
                response = requests.get(f"{base_url}{endpoint}", timeout=5)
                results.append({
                    'endpoint': endpoint,
                    'status_code': response.status_code,
                    'healthy': response.status_code == 200
                })
            except Exception as e:
                results.append({
                    'endpoint': endpoint,
                    'error': str(e),
                    'healthy': False
                })
        
        return results
    
    @task()
    def send_alerts(website_results: list, api_results: list):
        """Send alerts if issues detected"""
        issues = []
        
        # Check website results
        for result in website_results:
            if result.get('status') != 'UP':
                issues.append(f"Website {result['url']} is {result.get('status')}")
        
        # Check API results
        for result in api_results:
            if not result.get('healthy'):
                issues.append(f"API endpoint {result['endpoint']} is unhealthy")
        
        if issues:
            # Send alert (implement your alerting logic)
            print("ALERTS:")
            for issue in issues:
                print(f"  - {issue}")
            
            # Example: Send to Slack, PagerDuty, etc.
            # slack_hook = SlackWebhookHook(slack_webhook_conn_id='slack')
            # slack_hook.send(text='\n'.join(issues))
        else:
            print("All systems operational")
        
        return len(issues)
    
    # Define pipeline
    website_health = check_website_health()
    api_health = check_api_endpoints()
    send_alerts(website_health, api_health)

# Instantiate DAG
dag_instance = infrastructure_monitoring_dag()
```

## Advanced Patterns

### 8. Dynamic Task Generation

```python
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
}

dag = DAG(
    'dynamic_task_generation',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False,
    tags=['advanced', 'dynamic'],
)

def process_partition(partition_id):
    """Process a data partition"""
    print(f"Processing partition: {partition_id}")
    # Add your processing logic here
    return f"Partition {partition_id} processed"

# Dynamically create tasks for each partition
partitions = ['partition_1', 'partition_2', 'partition_3', 'partition_4']

tasks = []
for partition in partitions:
    task = PythonOperator(
        task_id=f'process_{partition}',
        python_callable=process_partition,
        op_args=[partition],
        dag=dag,
    )
    tasks.append(task)

# Set dependencies (all tasks run in parallel)
# Or create sequential dependencies: tasks[0] >> tasks[1] >> tasks[2] >> tasks[3]
```

### 9. Branch Operator Example

```python
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator, BranchPythonOperator
from airflow.operators.dummy import DummyOperator

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2024, 1, 1),
}

dag = DAG(
    'branching_example',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False,
    tags=['advanced', 'branching'],
)

def check_data_volume(**context):
    """Decide which branch to take based on data volume"""
    # Simulate checking data volume
    data_volume = 1500  # GB
    
    if data_volume > 1000:
        return 'large_data_processing'
    else:
        return 'small_data_processing'

def process_large_data():
    print("Processing large dataset with distributed computing")

def process_small_data():
    print("Processing small dataset with single node")

start = DummyOperator(task_id='start', dag=dag)

branch = BranchPythonOperator(
    task_id='check_volume',
    python_callable=check_data_volume,
    provide_context=True,
    dag=dag,
)

large_processing = PythonOperator(
    task_id='large_data_processing',
    python_callable=process_large_data,
    dag=dag,
)

small_processing = PythonOperator(
    task_id='small_data_processing',
    python_callable=process_small_data,
    dag=dag,
)

end = DummyOperator(task_id='end', trigger_rule='none_failed_min_one_success', dag=dag)

start >> branch >> [large_processing, small_processing] >> end
```

## Best Practices

1. **Use TaskFlow API** for cleaner, more Pythonic DAGs
2. **Idempotency** - Tasks should produce same result when run multiple times
3. **Atomic tasks** - Each task should do one thing well
4. **Error handling** - Implement retries and proper error handling
5. **XCom wisely** - Don't pass large data through XCom
6. **Connection management** - Use Airflow connections for credentials
7. **Testing** - Test DAGs before deployment
8. **Monitoring** - Set up alerts for failed tasks
9. **Documentation** - Document DAG purpose and dependencies
10. **Resource management** - Be mindful of memory and CPU usage

## Running DAGs

```bash
# Test DAG
airflow dags test dag_id execution_date

# Trigger DAG manually
airflow dags trigger dag_id

# List all DAGs
airflow dags list

# Pause/Unpause DAG
airflow dags pause dag_id
airflow dags unpause dag_id

# View DAG structure
airflow dags show dag_id
```

## Summary

Apache Airflow enables:
- **Workflow orchestration** for data pipelines
- **Scheduled execution** of complex tasks
- **Dependency management** between tasks
- **Monitoring and alerting** for pipeline health
- **Scalable processing** with distributed executors

Use these examples as templates and customize them for your specific use cases.
