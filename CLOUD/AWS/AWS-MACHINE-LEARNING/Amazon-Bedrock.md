
## 🧠 What is Amazon Bedrock?

**Amazon Bedrock** is a **serverless platform** that lets you build and scale **generative AI applications** using **pre-trained Foundation Models (FMs)** from **leading AI companies**, via a unified API.  
You don’t need to manage GPUs, train models, or fine-tune from scratch.

> ✅ It supports text generation, summarization, chat, image generation, embeddings, and more.

---

## 🔗 Supported Foundation Model Providers (as of 2024)

|Provider|Models Offered|
|---|---|
|**Anthropic**|Claude 1, 2, 3 (for reasoning, chat, docs)|
|**Meta**|Llama 2 & 3|
|**Cohere**|Command R+, Embed models|
|**AI21 Labs**|Jurassic-2 (for text generation)|
|**Mistral AI**|Mistral 7B, Mixtral (Mixture-of-Experts)|
|**Stability AI**|Stable Diffusion (image generation)|
|**Amazon Titan**|Titan Text, Titan Embeddings, Titan Image|

---

## 🔧 Core Capabilities

|Feature|Description|
|---|---|
|**Text generation**|Chatbots, summarization, content creation|
|**Embeddings**|Semantic search, vector databases|
|**Image generation**|AI image creation with Stability AI|
|**Agents**|Automatically execute tasks with grounding and orchestration|
|**Knowledge bases**|Retrieval-Augmented Generation (RAG) over your enterprise data|
|**Model evaluation**|Compare models side by side in Studio|
|**Fine-tuning**|Train custom versions of Titan models|
|**Secure API access**|IAM-based auth, no model weights exposed|

---

## ✨ Example Use Cases

|Use Case|Example|
|---|---|
|Chatbot|Claude or Llama-based assistant|
|Document Q&A|Titan + RAG on S3 + OpenSearch|
|Image generator|Stability AI → Generate art from prompts|
|Embedding + search|Titan Embeddings + vector DB (e.g., Pinecone, FAISS)|
|Summarization|Upload PDFs → Claude → Text summary|
|Code generation|LLMs for code, CLI, function writing|

---

## 🧪 Sample Bedrock Python SDK (Boto3)

### Invoke Claude 3

```python
import boto3

bedrock = boto3.client('bedrock-runtime')

response = bedrock.invoke_model(
    modelId="anthropic.claude-3-sonnet-20240229-v1:0",
    contentType="application/json",
    accept="application/json",
    body=json.dumps({
        "messages": [
            {"role": "user", "content": "Explain quantum computing simply."}
        ],
        "max_tokens": 512
    })
)

print(json.loads(response['body'].read()))
```

---

### Embed text using Titan Embeddings

```python
response = bedrock.invoke_model(
    modelId="amazon.titan-embed-text-v1",
    contentType="application/json",
    accept="application/json",
    body=json.dumps({"inputText": "The capital of France is Paris."})
)

print(json.loads(response['body'].read())["embedding"])
```

---

## 📚 Knowledge Bases (RAG) Support

You can link Bedrock with:

- **Amazon OpenSearch**
    
- **Pinecone**
    
- **Redis Enterprise Cloud**
    

To build Retrieval-Augmented Generation (RAG) pipelines with vector search over:

- S3 PDFs, TXT
    
- Internal documents
    
- FAQs, Wikis
    

> ✅ Bedrock **natively supports RAG workflows** via “Knowledge Bases”.

---

## ⚙️ Bedrock Agents

Bedrock Agents allow models to:

- Use **tools (APIs, functions)** to complete tasks (e.g., book a ticket, fetch weather)
    
- Perform **reasoning over multi-step prompts**
    
- Combine **RAG + tools + models** with memory
    

---

## 🧾 Pricing Overview

|Feature|Price (2024 estimate)|
|---|---|
|Text generation (Claude 3)|$0.003 - $0.015 / 1K tokens (input/output)|
|Embeddings (Titan)|$0.0001 / 1K tokens|
|Image generation (Stable)|~$0.02 per image|
|Agents & KB|Usage-based + underlying model cost|

✅ You **pay only for what you use** (tokens in/out).

---

## 🔐 Security & Compliance

|Feature|Supported|
|---|---|
|IAM + API Gateway|✅ Yes|
|VPC support|✅ Yes via PrivateLink|
|Encryption (KMS)|✅ Yes|
|Logging (CloudTrail)|✅ Yes|
|HIPAA eligible|✅ Yes (Titan only)|
|Data stays in AWS|✅ Models don’t retain inputs|

---

## 🧱 Terraform Support

Bedrock resources are **not natively available** in Terraform (as of now), but you can:

- Use **Lambda + Bedrock Runtime API**
    
- Create knowledge base infrastructure using:
    
    - `aws_opensearch_domain`
        
    - `aws_s3_bucket`
        
    - `aws_lambda_function`
        

Terraform Sample (S3 for RAG):

```hcl
resource "aws_s3_bucket" "bedrock_knowledge_data" {
  bucket = "bedrock-rag-files"
  force_destroy = true
}
```

---

## 🧠 Bedrock vs Alternatives

|Service|Bedrock|OpenAI (API)|Vertex AI|
|---|---|---|---|
|Managed by AWS|✅ Yes|❌ No|✅ Yes|
|Multi-model hub|✅ Yes|❌ (OpenAI only)|✅ (limited)|
|Fine-tuning|✅ Titan only|✅ GPT-3.5/4 Turbo|✅|
|RAG Support|✅ Native KB + Agents|❌ (DIY)|✅|
|VPC Support|✅ Yes (PrivateLink)|❌ No|✅ Yes|

---

## ✅ TL;DR Summary

|Feature|Amazon Bedrock|
|---|---|
|Foundation Models|Claude, Llama, Titan, Cohere, AI21|
|Image generation|✅ Stability AI (SDXL)|
|Embeddings|✅ Titan, Cohere|
|Tools/Agents|✅ Orchestration of LLMs|
|RAG pipeline|✅ Built-in with Knowledge Base|
|Real-time inference|✅ Yes (no infra to manage)|
|Fine-tuning|✅ Titan Text/Image only|
|Terraform support|❌ Not yet full|
|Free tier|❌ No free tier yet|

---
