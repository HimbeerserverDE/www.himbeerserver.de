function sidebar_open() {
	let bar = document.getElementById("sidebar");
	bar.style.opacity = 1;

	if (screen.width < 500) {
		bar.style.width = "100%";
	} else {
		bar.style.width = "20%";
	}
}

function sidebar_close() {
	let bar = document.getElementById("sidebar");
	bar.style.opacity = 0;
	bar.style.width = 0;
}

function account_info() {
	document.location.href = "/account";
}
