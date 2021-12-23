let pages = {
	"Main Page": "/",
};

function sidebar_open() {
	let container = document.getElementById("container");
	let bar = document.getElementById("sidebar");
	bar.style.opacity = 1;

	if (screen.width < 500) {
		bar.style.width = "100%";
		container.style.width = 0;
	} else {
		bar.style.width = "20%";
		container.style.width = "80%";
	}
}

function sidebar_close() {
	let container = document.getElementById("container");
	let bar = document.getElementById("sidebar");

	bar.style.opacity = 0;
	bar.style.width = 0;
	container.style.width = "100%";
}

function sidebar_rd(path) {
	document.location.href = path;
}

function account_info() {
	document.location.href = "/account";
}

let i = 1;
for (let k in pages) {
	let sidebar = document.getElementById("sidebar");
	let div = document.createElement("div");

	div.className = "sb_btn";
	div.style.top = 5 + i*12.5 + "%";
	div.innerText = k;

	div.addEventListener("click", _ => {
		sidebar_rd(pages[k]);
	});

	sidebar.appendChild(div);
	i++;
}
