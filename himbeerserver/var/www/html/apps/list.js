async function updateList() {
	let ul = document.getElementById("applist");

	// clear the list if it contains anything
	for (let child of ul.children) {
		child.parentElement.removeChild(child);
	}

	let xhr = new XMLHttpRequest();
	xhr.open("GET", "/cgi-bin/apps/list.lua");
	xhr.setRequestHeader("Accept", "application/json")

	xhr.onerror = _ => {
		alert("Could not retrieve app list!");
	};

	xhr.onload = _ => {
		if (xhr.status !== 200) {
			xhr.onerror();
			return;
		}

		let list = JSON.parse(xhr.responseText);
		for (let app in list) {
			let path = list[app];

			let a = document.createElement("a");
			a.innerText = app;
			a.href = path;

			let li = document.createElement("li");
			li.appendChild(a);

			ul.appendChild(li);
		}
	};

	xhr.send();
}

updateList();
setInterval(updateList, 30000);
