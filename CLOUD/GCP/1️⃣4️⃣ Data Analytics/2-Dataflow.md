# Dataflow

Unified stream and batch data processing.

---

## Overview

Dataflow is a fully managed service for executing Apache Beam pipelines for batch and streaming data processing.

---

## Key Features

- Unified batch and stream processing
- Apache Beam SDK
- Auto-scaling
- Serverless
- Exactly-once processing
- Windowing
- State management

---

## Apache Beam Concepts

**Pipeline:** Data processing workflow  
**PCollection:** Distributed dataset  
**Transform:** Data processing operation  
**ParDo:** Parallel processing  
**GroupByKey:** Aggregation  
**Window:** Time-based grouping

---

## Basic Pipeline

**Python:**
```python
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions

# Define pipeline options
options = PipelineOptions(
    project='my-project',
    region='us-central1',
    runner='DataflowRunner',
    temp_location='gs://my-bucket/temp',
    staging_location='gs://my-bucket/staging'
)

# Create pipeline
with beam.Pipeline(options=options) as pipeline:
    (pipeline
     | 'Read' >> beam.io.ReadFromText('gs://my-bucket/input.txt')
     | 'Transform' >> beam.Map(lambda x: x.upper())
     | 'Write' >> beam.io.WriteToText('gs://my-bucket/output.txt'))
```

**Java:**
```java
PipelineOptions options = PipelineOptionsFactory.create();
options.setProject("my-project");
options.setRegion("us-central1");
options.setRunner(DataflowRunner.class);

Pipeline pipeline = Pipeline.create(options);

pipeline
    .apply("Read", TextIO.read().from("gs://my-bucket/input.txt"))
    .apply("Transform", MapElements.via(new SimpleFunction<String, String>() {
        public String apply(String input) {
            return input.toUpperCase();
        }
    }))
    .apply("Write", TextIO.write().to("gs://my-bucket/output"));

pipeline.run().waitUntilFinish();
```

---

## Streaming Pipeline

**Pub/Sub to BigQuery:**
```python
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.io.gcp.bigquery import WriteToBigQuery

options = PipelineOptions(
    streaming=True,
    project='my-project',
    region='us-central1',
    runner='DataflowRunner'
)

with beam.Pipeline(options=options) as pipeline:
    (pipeline
     | 'Read from Pub/Sub' >> beam.io.ReadFromPubSub(
         subscription='projects/my-project/subscriptions/my-sub')
     | 'Parse JSON' >> beam.Map(lambda x: json.loads(x.decode('utf-8')))
     | 'Transform' >> beam.Map(transform_data)
     | 'Write to BigQuery' >> WriteToBigQuery(
         'my-project:dataset.table',
         schema='id:INTEGER,name:STRING,timestamp:TIMESTAMP',
         write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND))
```

---

## Windowing

**Fixed Windows:**
```python
from apache_beam import window

(pipeline
 | 'Read' >> beam.io.ReadFromPubSub(subscription=subscription)
 | 'Parse' >> beam.Map(parse_json)
 | 'Window' >> beam.WindowInto(window.FixedWindows(60))  # 1-minute windows
 | 'Count' >> beam.combiners.Count.PerElement()
 | 'Write' >> beam.io.WriteToBigQuery(table_spec))
```

**Sliding Windows:**
```python
(pipeline
 | 'Read' >> beam.io.ReadFromPubSub(subscription=subscription)
 | 'Window' >> beam.WindowInto(
     window.SlidingWindows(size=300, period=60))  # 5-min window, 1-min slide
 | 'Aggregate' >> beam.CombineGlobally(
     beam.combiners.MeanCombineFn()).without_defaults()
 | 'Write' >> beam.io.WriteToBigQuery(table_spec))
```

**Session Windows:**
```python
(pipeline
 | 'Read' >> beam.io.ReadFromPubSub(subscription=subscription)
 | 'Window' >> beam.WindowInto(window.Sessions(gap_size=600))  # 10-min gap
 | 'GroupByKey' >> beam.GroupByKey()
 | 'Write' >> beam.io.WriteToBigQuery(table_spec))
```

---

## Transforms

**ParDo:**
```python
class ProcessElement(beam.DoFn):
    def process(self, element):
        # Process element
        result = transform_logic(element)
        yield result

(pipeline
 | 'Read' >> beam.io.ReadFromText('input.txt')
 | 'Process' >> beam.ParDo(ProcessElement())
 | 'Write' >> beam.io.WriteToText('output.txt'))
```

**GroupByKey:**
```python
(pipeline
 | 'Read' >> beam.io.ReadFromText('input.txt')
 | 'Parse' >> beam.Map(lambda x: (x.split(',')[0], x.split(',')[1]))
 | 'GroupByKey' >> beam.GroupByKey()
 | 'Sum' >> beam.Map(lambda kv: (kv[0], sum(int(v) for v in kv[1])))
 | 'Write' >> beam.io.WriteToText('output.txt'))
```

**Combine:**
```python
(pipeline
 | 'Read' >> beam.io.ReadFromText('input.txt')
 | 'Parse' >> beam.Map(lambda x: int(x))
 | 'Sum' >> beam.CombineGlobally(sum)
 | 'Write' >> beam.io.WriteToText('output.txt'))
```

---

## Side Inputs

```python
# Main pipeline
main_data = (pipeline
             | 'Read Main' >> beam.io.ReadFromText('main.txt'))

# Side input
lookup_data = (pipeline
               | 'Read Lookup' >> beam.io.ReadFromText('lookup.txt')
               | 'Parse Lookup' >> beam.Map(lambda x: tuple(x.split(',')))
               | 'To Dict' >> beam.combiners.ToDict())

# Use side input
result = (main_data
          | 'Enrich' >> beam.Map(
              enrich_with_lookup,
              lookup=beam.pvalue.AsDict(lookup_data)))
```

---

## Templates

**Create Template:**
```bash
# Run pipeline to create template
python my_pipeline.py \
  --runner=DataflowRunner \
  --project=my-project \
  --region=us-central1 \
  --template_location=gs://my-bucket/templates/my-template \
  --staging_location=gs://my-bucket/staging
```

**Execute Template:**
```bash
# Execute from template
gcloud dataflow jobs run my-job \
  --gcs-location=gs://my-bucket/templates/my-template \
  --region=us-central1 \
  --parameters input=gs://input-bucket/data.txt,output=gs://output-bucket/result
```

---

## Flex Templates

**Dockerfile:**
```dockerfile
FROM gcr.io/dataflow-templates-base/python3-template-launcher-base

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY my_pipeline.py .

ENV FLEX_TEMPLATE_PYTHON_PY_FILE="/template/my_pipeline.py"
```

**Build and Deploy:**
```bash
# Build image
gcloud builds submit --tag gcr.io/my-project/my-template .

# Create flex template
gcloud dataflow flex-template build gs://my-bucket/templates/my-flex-template.json \
  --image=gcr.io/my-project/my-template \
  --sdk-language=PYTHON

# Run flex template
gcloud dataflow flex-template run my-job \
  --template-file-gcs-location=gs://my-bucket/templates/my-flex-template.json \
  --region=us-central1 \
  --parameters input=gs://input/data.txt,output=gs://output/result
```

---

## Best Practices

✓ Use windowing appropriately  
✓ Implement idempotent transforms  
✓ Monitor pipeline metrics  
✓ Use side inputs efficiently  
✓ Implement error handling  
✓ Use appropriate machine types  
✓ Enable autoscaling  
✓ Test with sample data  

---

## Pricing

Based on:
- vCPU hours
- Memory GB hours
- Persistent disk GB hours
- Streaming engine (optional)

**Example:**
```
n1-standard-1: ~$0.056/hour
Streaming: 5% premium
Shuffle: Additional cost for large shuffles
```

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
