const user = "undefinedDarkness"

interface Repo {
	html_url: string,
	fork: boolean,
	description: string,
	full_name: string,
	name: string,
	url: string,
	source: Repo
}

async function print_repo(repo: Repo) {
	if (repo.fork) {
		fetch(repo.url)
			.then(r => r.json())
			.then((repo: Repo) => {
				console.log(`
<section>
<h3>Contributed to <a href="${repo.html_url}">${repo.source.full_name}</a></h3>
<p>${repo.description}</p>
</section>`)
			})
	} else {
		console.log(`
<section>
<h3>Created <a href="${repo.html_url}">${repo.name}</a></h3>
<p>${repo.description}</p>
</section>`)
	}
}

fetch(`https://api.github.com/users/${user}/repos`)
	.then(r => r.json())
	.then(repos => {
		if (!Array.isArray(repos)) {
			console.error(`Github API Rate Limit Reached. Wait for an hour or so`)
			Deno.exit(0)
		}
		repos.forEach(print_repo)
	})
