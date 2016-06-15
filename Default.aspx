<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="GetFBIDandPosition.Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="http://connect.facebook.net/zh_TW/all.js"></script>
    <script src="https://code.jquery.com/jquery-2.2.3.min.js" type="text/javascript"></script>
    <%--    
    <script type="text/javascript">
        window.fbAsyncInit = function () {
            FB.init({
                appId: '530297543820027',
                xfbml: true,
                version: 'v2.5'
            });
        };

        (function (d, s, id) {
            var js, fjs = d.getElementsByTagName(s)[0];
            if (d.getElementById(id)) { return; }
            js = d.createElement(s); js.id = id;
            js.src = "//connect.facebook.net/en_US/sdk.js";
            fjs.parentNode.insertBefore(js, fjs);
        }(document, 'script', 'facebook-jssdk'));
    </script>
    --%>
    <script type="text/javascript">
        var ary = new Array();
        var myTimer;
        $(document).ready(function () {
            FB.init({
                appId: "530297543820027",
                status: true,
                cookie: true,
                xfbml: true,
                oauth: true
            });

            //$("#FBLogin").click(function () {
            //    //var type = "作物";
            //    var type = $("#FBText").val();
            //    FB.login(function (response) {
            //        callFBfunc(type);
            //    }, { scope: "email" });
            //});

            $("#FBLogin").click(function () {
                //FB.login(function (response) {
                myTimer = setInterval(function () { callFBfunc() }, 30000);
                //});
            });
        });

        function stopTimer() {
            clearInterval(myTimer);
        }

        function callFBfunc() {
            var date = new Date();
            var dstr = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
            $("#spanFB").html(dstr);
            $.ajax({
                type: "POST",
                url: "Default.aspx/GetFBLocation",
                datatype: "json",
                contentType: 'application/json',
                async: false,
                //cache: false,
                data: {},
                success: function (result) {
                    ary = new Array();
                    //alert(result);
                    var Center = $.parseJSON(result.d);
                    //var Center = $.parseJSON($("<div/>").html(result).text());
                    for (var k = 0; k < Center.length; k++) {
                        var urlCall = "/search?q=&type=place&center=" + Center[k]["CE_X"] + ", " + Center[k]["CE_Y"] + "&distance=4500";
                        FB.api(urlCall, function (res) {
                            //debugger;
                            for (var i = 0; i < res.data.length; i++) {
                                //asd1 += response.data[i].location.latitude + " " + response.data[i].location.longitude + "<br>";
                                var country = "";
                                if (res.data[i]["location"]["country"] != "" && typeof(res.data[i]["location"]["country"]) != "undefined") {
                                    country = res.data[i]["location"]["country"];
                                }
                                var id = res.data[i].id;
                                var name = res.data[i].name
                                var category = res.data[i].category;
                                var location = res.data[i].location;
                                var longitude = res.data[i].location.longitude;
                                var latitude = res.data[i].location.latitude;
                                var obj = {
                                    id: id,
                                    name: name,
                                    type: "",
                                    category: category,
                                    checkins: 0,
                                    likes: 0,
                                    talking_about_count: 0,
                                    were_here_count: 0,
                                    country: country,
                                    location: location,
                                    parking: "",
                                    geom_location: "",
                                    longitude: longitude,
                                    latitude: latitude
                                };
                                $.ajax({
                                    type: "POST",
                                    url: 'Default.aspx/AddFBPlace',
                                    datatype: "json",
                                    contentType: 'application/json',
                                    async: false,
                                    data: JSON.stringify({ data: obj }),
                                    success: function (result) {
                                        ary.push(id);
                                        //$("#uid").html("UID：" + res.data[i]["id"]);
                                    }
                                });
                            }
                        });
                        upd(Center[k]["CE_ID"]);
                    }
                    $("#uid").html(ary.join(",</br>"));

                },
                error: function (data) {
                    var err = JSON.stringify(data);
                    //alert(err);
                }
            });
            //var urlCall = "/search?q=" + type + "&type=place&center=Taiwan&distance=1000";
            ////distance-公尺(台灣全島南北縱長約395公里)
            //FB.api(urlCall, function (res) {
            //    debugger;
            //    //alert(response.data[0]["id"]);
            //    //$("#uid").html("UID：" + response.data[0]["id"]);
            //    del({ type: type });
            //    for (var i = 0; i < res.data.length; i++) {
            //        //alert(res.data[i]["id"]);
            //        var country = "";
            //        if (res.data[i]["location"]["country"] != "" && typeof(res.data[i]["location"]["country"]) != "undefined") {
            //            country = res.data[i]["location"]["country"];
            //        }
            //        var obj = {
            //            id: res.data[i]["id"],
            //            name: res.data[i]["name"],
            //            type: type,
            //            category: res.data[i]["category"],
            //            checkins: 0,
            //            likes: 0,
            //            talking_about_count: 0,
            //            were_here_count: 0,
            //            country: country,
            //            location: res.data[i]["location"],
            //            parking: "",
            //            geom_location: "",
            //            longitude: res.data[i]["location"]["longitude"],
            //            latitude: res.data[i]["location"]["latitude"]
            //        };
            //        add(obj);
            //    }
            //alert("完成");
        }

        //FB.getLoginStatus(function (response) {
        //    if (response.status === "connected") {
        //        // 程式有連結到 Facebook 帳號
        //        var uid = response.authResponse.userID; // 取得 UID
        //        var accessToken = response.authResponse.accessToken; // 取得 accessToken
        //        $("#uid").html("UID：" + uid);
        //        $("#accessToken").html("accessToken：" + accessToken);
        //    }
        //    else if (response.status === "not_authorized") {  // 帳號沒有連結到 Facebook 程式
        //        alert("請允許授權！");
        //    }
        //    else {    // 帳號沒有登入
        //        // 在本例子中，此段永遠不會進入...XD
        //    }
        //});

        function add(options) {
            return this._api('AddFBPlace', { data: options });
        }

        function del(options) {
            return this._api('DelFBPlace', { data: options });
        }

        function upd(id) {
            return this._api('UpdFBLocation', { id: id });
        }
        function _api(api, data) {
            return $.ajax({
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json',
                url: 'Default.aspx/' + api,
                async: false,
                data: JSON.stringify(data),
                dataFilter: function (data) {
                    var jobj = JSON.parse(data);

                    return jobj.hasOwnProperty('d') ? jobj.d : jobj;
                },
                error: function (data) {
                    var err = JSON.stringify(data);
                    //alert(err);
                }
            });
        }
    </script>
</head>
<body>

    <form id="form1" runat="server">
        <div>
            <div id="fb-root">
            </div>
            <p>
                <%--<input id="FBText" type="text" placeholder="填入要搜尋的字" />--%>
                <input id="FBLogin" type="button" value="登入臉書" />&nbsp;
                <input id="stopTimer" type="button" value="暫停" onclick="stopTimer()"/><br/><br/>
                更新時間：<span ID="spanFB"></span>
            </p>
            <p>
                <span id="uid"></span>
                <br />
                <span id="accessToken"></span>
            </p>

            <%--<asp:Button ID="Button1" runat="server" Text="Button" OnClick="Button1_Click" />--%>
        </div>
    </form>
</body>
</html>
