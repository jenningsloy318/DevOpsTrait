# Web Tips

- when sometimes we want to print a html page with code, but the code is a block with scroll bar, it will not display all codes when printing, so we edit the css file
  - select the code block, and then right click and select `inspect`, we will find the css element that used for the code block, as shown below, the code is in `<pre>` and `pre>code`
    ![codeblock](images/enable-html-page-code-display-all-witout-scroll-01.png)
  - increase the page size `max-width`, the default is `90 inch`,we can increase to `120 inch` because some code block may be too long, or we can directly set to `max-content`
    ![codeblock2](images/enable-html-page-code-display-all-witout-scroll-02.png)
  - modify the `</pre>` and `pre>code`, change or add `overflow-x: hidden;` and `white-space: pre-wrap;`
    ![codeblock3](images/enable-html-page-code-display-all-witout-scroll-03.png)
  - after that, we can print the page to pdf with full code included
