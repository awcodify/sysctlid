---
layout: post
title:  "Apa itu Performance Engineering ?"
description: Displin ilmu ini akan melakukan tes, analisa, rekomendasi, hingga *tuning* terhadap suatu sistem / aplikasi untuk memastikan semuanya dapat berjalan dengan baik secara teknikal.
categories: performance-engineering
tags: performance 
author: awcodify
---
Sebelum terlalu jauh membahas bagaimana melakukan *performance engineering*,  ada baiknya kita mengetahui terlebih dahulu gambaran singkat tentang *performance engineering*. Displin ilmu ini akan melakukan tes, analisa, rekomendasi, hingga *tuning* terhadap suatu sistem / aplikasi untuk memastikan semuanya dapat berjalan dengan baik secara teknikal.
<!--more-->

# Apa itu Performance Engineering ?
Displin ilmu ini akan melakukan tes, analisa, rekomendasi, hingga *tuning* terhadap suatu sistem / aplikasi untuk memastikan semuanya dapat berjalan dengan baik secara teknikal (contohnya; *response time, throughput, CPU utilization*), bebeda dengan *Quality Assurance* (QA) yang menggunakan pendekatan fungsional (contohnya: fitur login wajib menggunakan email yang valid). 

*Performance engineering* belum terlalu populer di Indonesia. Hanya beberapa perusahaan yang memang secara khusus mengadopsi *performance engineering*. Kebanyakan perusahaan / startup di Indonesia menggunakan *performance testing* sebagai *part of* SRE dan sebagian lainnya masuk di bagian QA. Lalu apa bedanya *performance engineering* dan *performance testing*?

## *Performance Engineering* vs *Performance Testing*

Keduanya sebenernya adalah hal yang sama karena *performance testing* adalah *part of performance engineering*. Dimana seorang *performance engineer* akan menggunakan hasil dari *performance test*  untuk melakukan analisa dan memberikan rekomendasi kepada tim development. 

*Performance Tester* akan melakukan tes terhadap aplikasi atau sistem dan mencari tahu bagaimana *response time*-nya ketika diberikan load yang tinggi. Sementara *Performance Engineer* akan mencari tahu dan menganalisa bagaimana/mengapa sistem dapat menghasilkan sekian *response time* tersebut. Seorang *Performance Engineer* akan mencari *bottleneck* dan memastikan sistem / aplikasi dapat memenuhi kebutuhan ***performance, scalability, and reliability***. Bahkan dengan *performance engineering* kita dapat melakukan ***cost-saving***. Bagaimana bisa? Kita akan membahas hal ini di  artikel selanjutnya tentang ["Mengapa Kita Membutuhkan *Performance Engineering?*"]({%  post_url  2021-05-08-seberapa-penting-performance-engineering %}).
