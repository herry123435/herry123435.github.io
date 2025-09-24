---
layout: page
title: Comparing pre-trained vs. Learned Embeddings for NLP Tasks
description: 
img: /assets/img/NLPTP_Intro.png
importance: 6
category: work
---

Our project investigates a fundamental trade-off in Natural Language Processing (NLP): When is it better to use general-purpose, pre-trained word embeddings versus training them from scratch for a specific task?

We explored this question by comparing three different approaches on a spam classification task using the Enron-Spam dataset:

1. Learned Embeddings: A model where word vectors start as random values and are learned specifically for our spam detection task.

2. Pre-trained Embeddings (Fixed): A model that uses GloVe embeddings (vectors trained on a massive, general dataset) but keeps them "frozen" and does not update them during training.

3. Pre-trained Embeddings (Fine-Tuned): A model that starts with GloVe embeddings but allows them to be further trained and adjusted ("fine-tuned") for our specific spam detection task.

Our goal was to measure the impact of these choices on two key metrics: model accuracy and training time. <br>
We found a clear and interesting trade-off between these methods:

- Fixed Pre-trained Embeddings are fast but inaccurate.
- Learned Embeddings are accurate but take time to learn.
- Fine-Tuned Pre-trained Embeddings offer the best of both worlds.

<div class="row justify-content-center my-4">
  <div class="col-lg-10">
    <object
      data="{{ '/assets/pdf/NLPTP.pdf#toolbar=0' | relative_url }}"
      type="application/pdf"
      width="100%"
      height="700"
    >
      <iframe
        src="{{ '/assets/pdf/NLPTP.pdf' | relative_url }}"
        width="100%"
        height="700"
        style="border: none;"
      ></iframe>
      <p>
        브라우저에서 PDF 미리보기를 지원하지 않는 경우입니다.
        <a href="{{ '/assets/pdf/NLPTP.pdf' | relative_url }}">PDF 다운로드</a>
      </p>
    </object>
  </div>
</div>