function sleep(e){return new Promise((t=>setTimeout(t,e)))}function categoriesBarActive(){var e=window.location.pathname;if("/"==(e=decodeURIComponent(e)))document.querySelector("#category-bar")&&document.getElementById("主页").classList.add("select");else{if(/\/categories\/.*?\//.test(e)){var t=e.split("/")[2];document.querySelector("#category-bar")&&document.getElementById(t).classList.add("select")}}}function topCategoriesBarScroll(){if(document.getElementById("category-bar-items")){let e=document.getElementById("category-bar-items");e.addEventListener("mousewheel",(function(t){let o=-t.wheelDelta/2;e.scrollLeft+=o,t.preventDefault()}),!1)}}function tagsBarActive(){var e=window.location.pathname;if("/"==(e=decodeURIComponent(e)))document.querySelector("#tags-bar")&&document.getElementById("首页").classList.add("select");else{if(/\/tags\/.*?\//.test(e)){var t=e.split("/")[2];document.querySelector("#category-bar")&&document.getElementById(t).classList.add("select")}}}sleep(2e3).then((()=>{})),categoriesBarActive(),topCategoriesBarScroll(),tagsBarActive();