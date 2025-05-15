---
layout: default
title: Contact
---

<link rel="stylesheet" href="/assets/css/contact.css">

<div id="contact">
  <h1 class="pageTitle">Contact Me</h1>
  <div class="contactContent">
    <p>Welcome to our Contact page. If you need assistance or have any questions, please use the form below to get in touch.</p>
    <p>If you have any feedback or encounter issues, you can also create an issue on our <a href="https://github.com/awcodify/sysctlid">GitHub repository</a>.</p>
    <p>Thank you for reaching out. We look forward to hearing from you!</p>
  </div>

  <form action="https://formspree.io/f/xzbldqbr" method="POST">
    <div>
      <label for="name">Name</label>
      <input type="text" id="name" name="name" class="full-width">
    </div>
    
    <div>
      <label for="email">Email Address</label>
      <input type="email" id="email" name="_replyto" class="full-width">
    </div>
    
    <div>
      <label for="message">Message</label>
      <textarea name="message" id="message" cols="30" rows="10" class="full-width"></textarea>
    </div>
    
    <div>
      <input type="submit" value="Send" class="button">
    </div>
  </form>
</div>
