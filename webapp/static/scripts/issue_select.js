
$(document).ready(function() {

    let getEmployees = function(model, manufacturer) {
        $.ajax({
            method: 'GET',
            url: '/modeldevices',
            data: {'modelnumber': model, 'manufacturer': manufacturer}
        })
        .done(function(msg) {
            if (msg['error']) {
                alert("Error contacting database\nCheck console for message");
                console.log(msg);
            } else {
                devices = msg['devices']
                $('#deviceid').empty();
                for(let i = 0; i < devices.length; i++) {
                    let op = new Option(devices[i], devices[i]);
                    $('#deviceid').append(op);
                }
            }
        });
    }

    $('#manufacturer').on('change', function(e){
        // this value
        let manufacturer = $(this).val()
        let modelNumber = $('#model_number').val()
        getEmployees(manufacturer, modelNumber);
    });

    $('#model_number').on('change', function(e){
        let manufacturer = $('#manufacturer').val()
        let modelNumber =  $(this).val()
        getEmployees(manufacturer, modelNumber);
    });


    getEmployees(
        $('#model_number').val(),
        $('#manufacturer').val()
    );
});
