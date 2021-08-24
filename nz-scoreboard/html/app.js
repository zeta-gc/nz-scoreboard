QBScoreboard = {}

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "open":
                QBScoreboard.Open(event.data);
                break;
            case "close":
                QBScoreboard.Close();
                break;
            case 'updatePlayerJobs':
                var jobs = event.data.jobs;
    
                $('#player_count').html(jobs.player_count);
    
                $('#ems').html(jobs.ems);
                $('#police').html(jobs.police);
                $('#cardealer').html(jobs.cardealer);
                $('#mechanic').html(jobs.mechanic);
                $('#import').html(jobs.import);
                $('#groove').html(jobs.groove);
                $('#ammu').html(jobs.ammu);
                $('#taxi').html(jobs.taxi);
                $('#staff').html(jobs.taxi);
                    
                break;
        }
    })
});

function sortPlayerList() {
	var table = $('#playerlist'),
		rows = $('tr:not(.heading)', table);

	rows.sort(function(a, b) {
		var keyA = $('td', a).eq(1).html();
		var keyB = $('td', b).eq(1).html();

		return (keyA - keyB);
	});

	rows.each(function(index, row) {
		table.append(row);
	});
}

QBScoreboard.Open = function(data) {

    $(".scoreboard-block").fadeIn(150);
    $("#total-players").html("<p>"+data.players+"/"+data.maxPlayers+"</p>");
    $("#job").html("<p>"+data.job+"</p>");


    $.each(data.requiredCops, function(i, category){
        var beam = $(".scoreboard-info").find('[data-type="'+i+'"]');
        var status = $(beam).find(".info-beam-status");


        if (category.busy) {
            $(status).html('<i class="fas fa-clock"></i>');
        } else if (data.currentCops >= category.minimum) {
            $(status).html('<i class="fas fa-check"></i>');
        } else {
            $(status).html('<i class="fas fa-times"></i>');
        }
    });





    var eventCallback = {


        setText: function(data) {
            var key = document.querySelector('#'+data.id+' span');
            var html = data.value;
            saferInnerHTML(key, html);
        }
    }

}

QBScoreboard.Close = function() {
    $(".scoreboard-block").fadeOut(150);
}
