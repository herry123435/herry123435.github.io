---
layout: page
title: Adapter Module for Computer Vision Transformer
description: 
img: /assets/img/structure.JPG
importance: 5
category: work
---

Efficient way to fine-tune large, pre-trained Vision Transformer (ViT) models for new tasks.

The Core Problem and Our Idea 💡 <br>
State-of-the-art ViT models are massive and powerful, but adapting them to a new, specific dataset (a "downstream task") requires "fine-tuning" the entire model. This is problematic for two main reasons:

1. It's expensive: Training entire parameters in a ViT requires significant computational power and time.
2. It's inefficient: You have to save a complete, separate copy of the massive model for every single new task.

We looked to the field of Natural Language Processing (NLP), where researchers had developed a clever solution for their transformer models called adapter modules. Our central idea was to see if we could successfully apply this same technique to the computer vision domain with ViTs.

An adapter module is a very small set of new layers that we insert into the existing architecture of a pre-trained model. The key is that we freeze all the original weights of the giant ViT and only train our small, new adapter modules. If this works, we can adapt a ViT to a new task by only training and saving a tiny fraction of the parameters, making the whole process much cheaper and more efficient.

Initially, our project faced significant challenges, as the model consistently suffered from severe overfitting, leading to poor performance. However, this was overcome by implementing improved regularization techniques, including a learning rate warm-up and specific weight initialization methods. This refined approach dramatically unlocked the model's potential, allowing it to achieve near state-of-the-art results, such as 90.5% test accuracy on CIFAR-100.

Ultimately, our work demonstrates that adapter modules hold significant promise and can be a highly effective and useful tool for various computer vision tasks when paired with a proper training regime.


<div class="row justify-content-center my-4">
  <div class="col-lg-10">
    <object
      data="{{ '/assets/pdf/DLTP.pdf#toolbar=0' | relative_url }}"
      type="application/pdf"
      width="100%"
      height="700"
    >
      <iframe
        src="{{ '/assets/pdf/DLTP.pdf' | relative_url }}"
        width="100%"
        height="700"
        style="border: none;"
      ></iframe>
      <p>
        브라우저에서 PDF 미리보기를 지원하지 않는 경우입니다.
        <a href="{{ '/assets/pdf/DLTP.pdf' | relative_url }}">PDF 다운로드</a>
      </p>
    </object>
  </div>
</div>
