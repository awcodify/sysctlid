---
layout: post
title: "Jenis - Jenis Performance Testing"
description: Ada berbagai macam jenis performance testing, diantaranya stress test, load test, capacity test, endurance test, dll.
categories: Performance-Test
tags: performance test
author: awcodify
---
Ada berbagai macam performance testing. Hal ini dibedakan berdasarkan *goal* dan cara melakukan testnya. Mari kita bahas satu per satu.
<!--more-->
# Jenis - Jenis Performance Test
Ada berbagai macam performance testing. Hal ini dibedakan berdasarkan *goal* dan cara melakukan testnya. Mari kita bahas satu per satu. *discalimer: setiap organisasi mungkin memiliki istilah yang berbeda. Namun, pada dasarnya definisinya sama.*

## Load Testing
Jenis tes ini akan dilakukan dengan menentukan *target load*. Biasanya digunakan untuk persiapan menghadapi sebuah event musiman yang trafiknya bertambah seiring waktu. Contohnya sistem kita kan melakukan penjualan mudik lebaran. Tentunya semakin mendekati waktu lebaran, maka ekpektasinya sistem akan menerima trafik yang lebih banyak. Jadi, dengan melakukan *load testing* kita akan mengatahui apakah sistem kita sanggup *handle* trafik sesuai ekspektasi kita.

Load testing biasanya dilakukan dengan ***scalability testing*** juga, yaitu menaikkan load perlahan - lahan pada setiap skenarionya, kemudian memonitor penggunaan resourcenya apakah ada perbedaan yang signifikan atau tidak. Contohnya: penggunaan CPU dan *memory* atau melihat bagaimana behaviour sistem ketika *scale up* atau *scale down* apakah telat atau terlalu cepat melakukan *scaling*.

## Spike Testing
*Load* dan *spike testing* adalah hal yang mirip, keduanya bertujuan untuk mengetahui apakah sistem mampu *handle* trafik sesuai ekspektasi. Bedanya, sesuai namanya, *spike* testing dilakukan dengan mengirim *load* secara mendadak dalam waktu yang bersamaan. Contoh *case* yang bisa digunakan adalah event pengisian KRS di kampus atau pendaftaran penerimaan CPNS dimana trafik yang datang akan cenderung mendadak pada tanggal dan waktu yang sama.

## Stress Testing
Saya lebih suka menyebutnya *capacity testing*, yaitu melakukan tes dengan load diluar ekspektasi hingga sistem tidak mampu lagi *handle* trafiknya. Tujuannya jelas, untuk mengetahui kapasitas sistem yang sedang berjalan.

## Soak Testing
Saya lebih suka menyebutnya *endurance testing* dimana kita akan melakukan tes dengan load yang normal, namun dalam waktu yang panjang. Tujuannya untuk melakukan analisa dan evaluasi behaviour sistem kita. Biasanya digunakan untuk mengetahui apakah sistem akan mengalami *memory leaks* pada penggunaan jangka panjang. Apa itu *memory leaks*  dan  bagaimana *impact* terhadap performa? Kita akan membahas pada artikel terpisah.

4 jenis tes diatas adalah tes yang paling umum dilakukan. Namun, ada beberapa jenis tes lain yang biasa saya lakukan dan penting juga, *volumne testing*.

## Volume Testing
Tes ini dilakukan untuk melihat bagaimana *behaviour* sistem ketika memiliki data yang sangat besar. Biasanya tes dilukan bertahap dimulai dari jumlah data yang masih sedikit di *database*, kemudian akan kita tambah terus menerus datanya sampai jumlahnya sangat besar. Tujuannya tidak lain untuk kesiapan sistem secara *long term*. Dimana semakin lama sistem digunakan, biasanya akan semakin besar data yang disimpan. Contohnya: data transaksi  yang memang harus disimpan terus sebagai rekap.