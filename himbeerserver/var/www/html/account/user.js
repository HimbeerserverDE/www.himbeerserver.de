user_info(resp => {
	let username = document.getElementById("username");
	let avatar = document.getElementById("avatar");

	username.innerText = resp.login;
	avatar.src = resp.avatar_url;
});
