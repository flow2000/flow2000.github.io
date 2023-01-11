// 侧边栏访问统计
fetch('https://v6-widget.51.la/v6/JnHw7yNkc1XsvRUB/quote.js').then(res => res.text()).then((data) => {
	let title = ['最近活跃访客', '今日访问人数', '今日访问量', '昨日人数', '昨日访问量', '本月访问量', '总访问量']
	let num = data.match(/(?<=<\/span><span>).*?(?=<\/span><\/p>)/g)
	let s = document.querySelectorAll('#visitor .content')[0]
	if (s !== undefined) {
		for (let i = 0; i < num.length; i++) {
			if (i == 3 || i == 4) continue;
			s.innerHTML += '<div><p><span id=name>' + title[i] + '</span><span class="num">' + num[i] + '</span></p></div>'
		}
	}
}); 