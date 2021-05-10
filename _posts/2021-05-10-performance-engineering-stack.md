---
layout: post
title: "Menjadi Seorang Performance Engineer"
categories: performance-engineering
tags: performance
author: root
---
<!--more-->
# Performance Engineering Stack
Setelah kita mengenal [apa itu performance engineering]({% post_url 2021-05-07-apa-itu-performance-engineering %}) dan [mengapa kita Membutuhkannya]({% post_url 2021-05-08-seberapa-penting-performance-engineering %}), sekarang sebelum membahas lebih dalam, mari kita lihat gambaran stack apa aja yang biasa digunakan dan apa saja yang dikerjakan seorang *performance engineer*. *Disclaimer: tasks dan stack tiap perusahaan pasti berbeda - beda. Apa yang saya tulis disini adalah pengalaman saya pribadi.*

Dalam dunia *performance engineering*, saat melakukan *performance test* ada beberapa fase yang akan kita lakukan:

## Prepare
Pada tahap ini kita akan melalukan *requirement gathring* bersama tim bisnis dan tim *development* untuk mengetahui kebutuhannya seperti apa. Misalkan bagaimana flow aplikasi yang akan kita tes atau berapa trafik yang diekspektasikan saat promo yang akan datang.

## Build
Meninterpretasikan hasil *requirement gathering• menjadi *test script*, menyiapkan data - data yang diperlukan, dan membuat environment (melakukan *deployment*) untuk melakukan tes. Seorang *performance engineer* sudah seharusnya bisa melakukan *deployment* sendiri karena saat melakukan test, kemungkinan kita akan melakukan *compare* beberapa versi atau tuning config, sehingga agar tidak menjadi *bottleneck* (tunggu menunggu dan antri di tim devops) akan jauh lebih baik dan produktif jika kita bisa melakukan *deployment* sendiri. Beberapa stack dalam *deployment* yang biasa digunakan: terraform, ansible, kubernetes.

## Execute
Melakukan test dan *collect metrics* (*Resource utilization, throughput, response time, error rate*, dll). Tool yang biasa kita gunakan untuk melakukan tes adalah k6, JMeter, Locust, WAPT Pro, Vegeta, dll. Selain itu, saat melakukan testing kita perlu tool untuk melakukan monitoring seperti Prometheus, NewRelics, Datadog, ELK.

## Analyze
Melakukan analisa terhadap hasil test yang dilakukan: mencari *bottleneck* dan *root cause*. Pada tahapan ini, secara garis besar ada dua hal yang kita perhatikan: *infra-related* dan *coding-related*. Jadi kita harus memiliki pemahaman yang baik di arsitektur infra dan *how the code works*.

## Optimize
Memberikan rekomendasi untuk improve performance. Misalkan eliminasi *infrastructur flow* untuk mengurangi *latency*, memberikan perhitungan *thread* dan *pool* yang ideal, melakukan *caching* terhadap data yang relatif statis, membuat *database cluster*, dll.

Selain itu, sebagai seorang *performance engineer* kita juga dituntut untuk sering melakukan riset, sehingga selalu *up to date* dengan perkembangan teknologi atau misalkan melakukan benchmark terhadap beberapa tools yang akan kita gunakan.

Kesimpulannya untuk menjadi seorang *performance engineer* skillset yang perlu kita miliki adalah: tech infrastructure-related things, code-related things, requirement gathering, dan analisis. Looks like a nightmare ya? 😁 Kalo dilihat sekilas, seperti disuruh menjadi *superhero* yang bisa melakukan semuanya. Maka dari itu, idealnya untuk menjadi seorang *performance engineer*, kita harus memiliki pengalaman terlebih dahulu di dunia *software engineering*. Dan seharusnya tidak akan terlalu berat *load*-nya jika saat melakukan *performance engineering* kita berdiskusi dan berjalan bersamaan dengan yang lain. Misalkan saat mencari *bottleneck* di infra flow,kita bisa berkolaborasi dengan devops atau jika ingin melakukan optimasi *query* bisa berkolaborasi dengan tim coding.