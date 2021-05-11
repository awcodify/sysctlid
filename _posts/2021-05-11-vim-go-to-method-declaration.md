---
layout: post
title: "VIM Go To Method Definition"
description: Cara pergi langsung ke method yang ada di cursor pada VIM seperti VSCODE.
categories: tutorial
tags: coding tutorial
author: awcodify@gmail.com
---
Salah satu fitur paling populer yang membuat kita menjadi produktif di text-editor modern adalah kita dapat langsung menuju *method definition* saat kita ctrl+klik pada nama method. Bagaimana melakukannya di VIM?
<!--more-->
Sekarang 2021 dan saya masih menjadi pengguna setia VIM (sebenarnya NVIM sih 🙂). Tidak perlu berdebat tentang *code editor* terbaik, karena itu adalah preferensi dan sesuai dengan kebutuhan masing - masing. Alasan kuat saya sampai saat ini adalah saya sudah membuat VIM bisa *handle* semua kebutuhan saya. Kemudian karena sebagai *performance engineer* banyak bermain - main di terminal, saya merasa lebih produktif jika banyak hal dapat di lakukan hanya di terminal saja tanpa harus berpindah - pindah tool.

Namun, salah satu fitur yang biasa ada di *modern code editor* adalah kemudahan untuk mengakses *method definition* hanya dengan satu  (ctrl+klik). Tapi tenang saja, kita juga bisa melakukannya di VIM dengan:

* `gd` akan ke *local definition*.
* `gD` akan ke  *global definition*.

Lebih lengkap bisa dibaca di: https://vim.fandom.com/wiki/Go_to_definition_using_g. Atau kalo mau *the hard way* bisa membuat custom function seperti dibawah:

```
function! SearchForDeclarationCursor()
    let searchTerm = 'func ' . expand("<cword>")
    cexpr system('Ag ' . shellescape(searchTerm))
endfunction
```
Oh iya, sebelumnya jangan lupa untuk instal silver searcher dulu ya.
```
brew install the_silver_searcher
#or
apt install silversearcher-ag

https://github.com/ggreer/the_silver_searcher
```
lalu kita mapping function diatas:
```
map <Leader>cd :call SearchForDeclarationCursor()<CR>
```
VIOLA! Sekarang kita punya fitur *go to method declaration* di VIM seperti VSCODE, Sublime, dll. *Code* diatas hanya *support* untuk Golang, tetapi sebenarnya bisa kita modif untuk support banyak *programming language*. Silahkan dicoba untuk dimodif sendiri ya! 😀

*Anyway*, ini *content* pertama di luar *performance engineering*. Ya, kita tidak hanya akan membahas tentang *perfeng*, melainkan banyak hal di dunia *technology*. Kamu juga bisa berkontribusi untuk menulis  melalui *pull request* ke [repositori sysctl.id](https://github.com/awcodify/sysctlid). Ditunggu kontribusinya ya!