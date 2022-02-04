const $ = _ => document.querySelector(_)
const Colors = ['#9e0142', '#d53e4f', '#f46d43', '#fdae61', '#fee08b', '#ffffbf', '#e6f598', '#abdda4', '#66c2a5', '#3288bd', '#5e4fa2'] 

fetch('/out/ricing/graphs/dataset.json').then(data => data.json()).then(datasets => {
	for (let set of datasets) {
		const ctx = $('#'+set.title+' > canvas');
		const chart = new Chart(ctx, {
			type: 'doughnut',
			data: {
				labels: set.labels,
				datasets: [{
					data: set.data,
					    backgroundColor: Colors
				}]
			},
			options: {
				plugins: {
					title: {
						display: true,
						text: set.title.toUpperCase()
					}
				},
				responsive: true
			}
		})
	}
})

