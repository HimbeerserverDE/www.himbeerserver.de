function log_in() {
	// ToDo: TLS support
	document.cookie = "LoginRedirect=" + document.location.href +
			"; Path=/; SameSite=Strict";

	document.location.href = "/account/login.html";
}

function user_info(callback) {
	let xhr = new XMLHttpRequest();
	xhr.open("GET", "/cgi-bin/account/info.lua");
	xhr.setRequestHeader("Accept", "application/json");
	xhr.onload = _ => {
		callback(JSON.parse(xhr.responseText));
	};
	xhr.send();
}

function update_account_info() {
	let xhr = new XMLHttpRequest();
	xhr.open("GET", "/cgi-bin/account/info.lua");
	xhr.onload = _ => {
		let btn = document.getElementById("acc");

		if (xhr.status === 200) {
			btn.onclick = account_info;
			btn.innerHTML = "👤";
		} else if (xhr.status === 401) {
			btn.onclick = log_in;
			btn.innerHTML = "🔐";
		} else {
			btn.onclick = null;
			btn.innerHTML = "✗";
		}
	};
	xhr.send();
}

update_account_info();
