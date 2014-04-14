// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
// require jquery
// require jquery_ujs
//= require turbolinks
//= require underscore
//= require backbone
//= require backbone_rails_sync
//= require backbone_datalink
//= require backbone/ms_robot
//= require_tree .


// Define global variable
// milisecond of day
var DAY_MILI_SERCOND = 24 * 60 * 60 * 1000;

var MENU_LEFT_USER = [
    {
        'icon': "icon-dashboard",
        'link': "#\/",
        'text': "Dashboard"
    },
    {
        'icon': "icon-user",
        'link': "#\/parents",
        'text': "Parents"
    },
    {
        'icon': "icon-calendar",
        'link': "#\/events",
        'text': "Events"
    },
    {
        'icon': "icon-group",
        'link': "#\/group_contacts",
        'text': "Group Contacts"
    }
];

var MENU_LEFT_PARENT = [
    {
        'icon': "icon-dashboard",
        'link': "#\/",
        'text': "Dashboard"
    },
    {
        'icon': "icon-calendar",
        'link': "#\/events",
        'text': "Events"
    }
];

var URL_CREATE_PARENT = "/users/create_parent.json"
var URL_LIST_PARENT = "/users/list_parent.json"
var URL_CREATE_EVENT = "/events.json"

var LIST_HOUR = [
    "00:00",
    "00:30",
    "01:00",
    "01:30",
    "02:00",
    "02:30",
    "03:00",
    "03:30",
    "04:00",
    "04:30",
    "05:00",
    "05:30",
    "06:00",
    "06:30",
    "07:00",
    "07:30",
    "08:00",
    "08:30",
    "09:00",
    "10:00",
    "10:30",
    "11:00",
    "11:30",
    "12:00",
    "12:30",
    "13:00",
    "13:30",
    "14:00",
    "14:30",
    "15:00",
    "15:30",
    "16:00",
    "16:30",
    "17:00",
    "17:30",
    "18:00",
    "18:30",
    "19:00",
    "19:30",
    "20:00",
    "20:30",
    "21:00",
    "21:30",
    "22:00",
    "22:30",
    "23:00",
    "23:30"
]
//*****************************
// create, remove, get, read cookie when sign in

function createCookie(name, value, days) {
    if (days) {
        var date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        var expires = "; expires=" + date.toGMTString();
    }
    else var expires = "";
    document.cookie = name + "=" + value + expires + "; path=/";
}

function eraseCookie(name) {
    createCookie(name, "", -1);
}

function getCookie(name) {
    var regexp = new RegExp("(?:^" + name + "|;\\s*" + name + ")=(.*?)(?:;|$)", "g");
    var result = regexp.exec(document.cookie);
    return (result === null) ? null : result[1];
}

function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
    }
    return null;
}

//************* END ****************

// validate email

function validateEmail(email) {
    var re = /^(([^<()[\]\\.,;:\s@\"]+(\.[^<()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
}

//*****************************
// ajax

function postAjax(type, data, url, callback) {
    $.ajax({
        type: type,
        url: url,
        data: data,
        success: function (response) {
            callback(response)
        },
        error: function (jqXHR, textStatus, errorThrown) {
            callback(jqXHR)
        }
    })
}

function getAjax(url, callback) {
    $.ajax({
        type: "GET",
        url: url,
        success: function (response) {
            callback(response)
        },
        error: function (jqXHR, textStatus, errorThrown) {
            callback(jqXHR)
        }
    })
}

//*****************************

function getDateFromNumber(date, number) {
    var d = new Date(date);
    var day = d.getDay();
    var getDate = new Date(date);
    if (number = day) {
        getDate = getDate.setDate(date.getDate() + (number - day));
    }
    return new Date(getDate);
}

function containsObject(elm, array) {
    for(var i=0; i<array.length; i++) {
        if (array[i].id == elm) {
            return true
        }
    }
    return false
}