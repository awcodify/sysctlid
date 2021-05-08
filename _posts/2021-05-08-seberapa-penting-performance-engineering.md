---
layout: post
title:  "Mengapa Performane Engineering Diperlukan?"
categories: performance-engineering
tags: performance
---

# Seberapa Penting *Performance Engineering*?
Mungkin saat ini sistem anda sudah berjalan dengan baik tanpa masalah. Entah karena memang sistem anda sudah baik atau saat ini beban yang dijalankan sistem belum terlalu berat saja? :) Kita tidak akan pernah tau jawabannya kecuali melalui 2 hal. Pertama, by event (atau mungkin by accident), dimana kita baru tahu dan kebakaran ketika tiba - tiba sistem kita menerima *load* yang tinggi. Kedua, melalui *performance engineering*

Sistem penerimaan pegawai baru, tiba - tiba tidak bisa diakses di hari pertama pembukaan pendaftaran. Sistem akademik, tiba - tiba sangat *lemot* saat mahasiswa berebutan mengisi KRS. *E-commerce* yang tiba - tiba `503` saat akan *checkout* di *flash sale*.  Penjualan tiket yang *error* saat mudik lebaran. Itu beberapa studi kasus dimana sistem anda akan memiliki *behaviour* yang berbeda dengan *daily*. Untuk itulah *performance engineering* sangat dibutuhkan dan beberapa pertanyaan yang sebenarnya mendasar dapat dijawab. 

>"Sistem kita kapasitasnya seberapa ya?"

>"Eh, sistem kita kuat ga nih kalo kita bikin promo?"

Dengan *performance engineering* kita akan melakukan *performance test* untuk mengukur kapasitas sistem, sehingga kita dapat memastikan bahwa sistem mampu meng-*handle* trafik yang diekspektasikan saat melakukan promo atau event. Pertanyaannya, setelah kita melakukan tes dan didapatkan hasil bahwa ternyata kapasitas kita tidak mampu untuk meng-*handle* ekspektasi trafik, lalu bagaimana? Apakah lantas kita harus menurunkan ekspektasi? Tentu hal ini tidak akan mudah bagi departemen bisnis / commercial / marketing untuk menurunkan ekspektasi.

 Jika kembali ke artikel sebelumnya, [apa itu performance engineering]({%  post_url  2021-05-07-apa-itu-performance-engineering %}), kita akan mengetahui bahwa sebagai seorang *performance engineer* sudah seharusnya memiliki kemampuan analisis yang baik untuk mencari *bottleneck* dan solusi yang terbaik untuk meningkatkan performa. Tapi IMHO ini bukanlah hal yang ideal untuk kita mencari solusi saat *injury time*, saat - saat dimana promo sudah ada di depan mata.

Disinilah sebenarnya disinilah `art of work` dari *performance engineering*. Dimana jika kita rutin menerapkannya dalam siklus development, tidak hanya departemen teknologi yang tahu kapasitas dan kemampuan sistem kita, sehingga dalam *decision making* akan mengurangi angka - angka magic (ekspektasi trafik dari tim bisnis yang kadang diluar nalar tech team 😅).

# Cost Optimization melalui Performance Engineering?

Salah satu *cost* yang paling tinggi di *tech company* adalah servers. Saat ini, sedang gencar - gancarnya di beberapa perusahaan unicorn dan *startups* melakukan *cost optimization* karena selama pandemic ini terjadi penurunan profit namun beban server tetap sama. Ketika kita di-*challenge* untuk melakukan *cost-optimization* dari sisi server, apakah kita dapat serta merta menurunkan spesifikasi server begitu saja? Tentu tidak! 😁

Tanpa melakukan *research* yang baik, kita tidak dapat mengetahui apa yang harus kita kurangi bebannya. Apalagi jika sistem kita sudah menerapkan *micro-services*. Service mana yang harus kita turunkan speknya? Apakah memang dari sisi aplikasi? Atau dari sisi database?  Atau bahkan kita tidak dapat melakukan pengurangan disisi manapun? Jangan - jangan malah bikin *server down*. dimana - mana? Who knows?

Dengan data historical dari *performance engineering*, kita akan mengetahui skala dan perbandingan penggunaan *resources*, kita juga tahu sisi mana yang membutuhkan resource lebih banyak dan mana yang lebih sedikit, bahkan kita juga mengetahui mana *service* yang *critical* dan yang tidak. Tentu saja dengan berbekal data - data ini, optimisasi yang kita lakukan akan menjadi lebih tepat sasaran. 

Intinya *performance engineering* bertujuan membuat development cycle kita menjadi lebih efektif dan efisien, serta mengurangi kesalahan - kesalahan kecil yang seharusnya tidak terjadi apalagi di *production-level*. Sudah ada gambaran kan? Selanjutnya kita akan membahas hal apa saja yang perlu dimiliki seseorang untuk menjadi seorang *performance engineer*?