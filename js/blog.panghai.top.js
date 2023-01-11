// 定义休眠函数
function sleep(time) {
	return new Promise((resolve) => setTimeout(resolve, time));
}
//分类条
function categoriesBarActive() {
	var urlinfo = window.location.pathname;
	urlinfo = decodeURIComponent(urlinfo)
	// console.log(urlinfo);
	//判断是否是首页			
	if (urlinfo == '/') {
		if (document.querySelector('#category-bar')) {
			document.getElementById('主页').classList.add("select")
		}
	} else {
		// 验证是否是分类链接
		var pattern = /\/categories\/.*?\//;
		var patbool = pattern.test(urlinfo);
		// 获取当前的分类
		if (patbool) {
			var valuegroup = urlinfo.split("/");
			// 获取当前分类
			// console.log(valuegroup[2]);
			var nowCategorie = valuegroup[2];
			if (document.querySelector('#category-bar')) {
				document.getElementById(nowCategorie).classList.add("select");
			}
		}
	}
}
//鼠标控制横向滚动
function topCategoriesBarScroll() {
	if (document.getElementById("category-bar-items")) {
		let xscroll = document.getElementById("category-bar-items");
		xscroll.addEventListener("mousewheel", function (e) {
			//计算鼠标滚轮滚动的距离
			let v = -e.wheelDelta / 2;
			xscroll.scrollLeft += v;
			//阻止浏览器默认方法
			e.preventDefault();
		}, false);
	}
}

//标签条
function tagsBarActive() {
	var urlinfo = window.location.pathname;
	urlinfo = decodeURIComponent(urlinfo)
	//console.log(urlinfo);
	//判断是否是首页
	if (urlinfo == '/') {
		if (document.querySelector('#tags-bar')) {
			document.getElementById('首页').classList.add("select")
		}
	} else {
		// 验证是否是分类链接
		var pattern = /\/tags\/.*?\//;
		var patbool = pattern.test(urlinfo);
		//console.log(patbool);
		// 获取当前的标签
		if (patbool) {
			var valuegroup = urlinfo.split("/");
			// console.log(valuegroup[2]);
			// 获取当前分类
			var nowTag = valuegroup[2];
			if (document.querySelector('#category-bar')) {
				document.getElementById(nowTag).classList.add("select");
			}
		}
	}
}


//休眠2秒
sleep(2000).then(() => {
	// console.clear();
	//console.log("%c欢迎访问我的博客，在这里你会看到我的日常技术分享，以及博客优化分享\n如果有哪个样式看着挺好的，想用在自己博客上，尽管拿去，但不要拿去做商业活动呦\n", "font-size:20px;line-height:28px;color:#00AAE1");
})



categoriesBarActive()
topCategoriesBarScroll()
tagsBarActive()

