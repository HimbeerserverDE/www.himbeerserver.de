function update_account_info() {
	let xhr = new XMLHttpRequest();
	xhr.open("GET", "/cgi-bin/account/info.lua");
	xhr.onload = _ => {
		let btn = document.getElementById("acc");
		if (xhr.status === 200) {
			btn.innerHTML = "👤";
		} else if (xhr.status === 401) {
			btn.innerHTML = "🔐";
		} else {
			btn.innerHTML = "✗";
		}
	};
	xhr.send();
}

update_account_info();
