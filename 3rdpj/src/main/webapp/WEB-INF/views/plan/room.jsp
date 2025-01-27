<%--
  Created by IntelliJ IDEA.
  User: 길영준
  Date: 2023-04-27
  Time: 오후 6:08
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<html lang="en">
<head>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet"
          integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
    <title></title>
</head>
<body>

<div class="container">
    <div class="col-6">
        <h1 id="room-name">채팅방</h1>
    </div>
    <div>
        <c:forEach var="log" items="${chatLog}">
            <c:if test="${log.send_id == sessionScope.user_id}">
                <div class='col-6'>
                    <div class='alert alert-secondary'>
                        <b> ${log.send_id} : ${log.msg_content}</b>
                        <fmt:formatDate pattern="MM-dd HH:mm" value="${log.create_date}"/>
                        <p>${log.read_yn}</p>
                    </div>
                </div>
            </c:if>
            <c:if test="${log.send_id != sessionScope.user_id}">
                <div class='col-6'>
                    <div class='alert alert-warning'>
                        <b> ${log.send_id} : ${log.msg_content} </b>
                        <fmt:formatDate pattern="MM-dd HH:mm" value="${log.create_date}"/>
                    </div>
                </div>
            </c:if>
        </c:forEach>
        <div id="msgArea" class="col"></div>
        <div class="col-6">
            <div class="input-group mb-3">
                <input type="text" id="msg" class="form-control">
                <div class="input-group-append">
                    <button class="btn btn-outline-secondary" type="button" id="button-send">전송</button>
                </div>
            </div>
        </div>
    </div>
    <div class="col-6"></div>
</div>

<script src="https://code.jquery.com/jquery-3.6.3.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM"
        crossorigin="anonymous">
</script>
<script>
    $(document).ready(function () {

        let roomId = '${room.msg_idx}';
        let username = '${sessionScope.user_id}';
        let receiveName = '';
        if (username === '${room.send_id}') {
            receiveName = '${room.receive_id}';
        } else {
            receiveName = '${room.send_id}';
        }

        console.log(roomId + ", " + username);

        let sockJs = new SockJS("/stomp/chat");
        //1. SockJS를 내부에 들고있는 stomp를 내어줌
        let stomp = Stomp.over(sockJs);

        //2. connection이 맺어지면 실행
        stomp.connect({}, function () {
            console.log("STOMP Connection")

            //4. subscribe(path, callback)으로 메세지를 받을 수 있음
            stomp.subscribe("/sub/chat/room/" + roomId, function (chat) {
                var content = JSON.parse(chat.body);

                var writer = content.send_id;
                var str = '';

                    let date = new Date().toLocaleString()
                if (writer === username) {
                    str = "<div class='col-6'>";
                    str += "<div class='alert alert-secondary'>";
                    str += "<b>" + writer + " : " + content.msg_content +"</b>";
                    str += "<p>" + date + "</p>"
                    str += "</div></div>";
                    $("#msgArea").append(str);
                } else {
                    str = "<div class='col-6'>";
                    str += "<div class='alert alert-warning'>";
                    str += "<b>" + writer + " : " + content.msg_content +  "</b>";
                    str += "<p>" + date + "</p>";
                    str += "</div></div>";
                    $("#msgArea").append(str);
                }

                // $("#msgArea").append(str);
            });

            //3. send(path, header, message)로 메세지를 보낼 수 있음
            stomp.send('/pub/chat/enter', {}, JSON.stringify({msg_idx: roomId, send_id: username}))
        });

        $("#button-send").on("click", function (e) {
            var msg = document.getElementById("msg");

            console.log(username + ":" + msg.value);
            stomp.send('/pub/chat/message', {}, JSON.stringify({
                msg_idx: roomId,
                msg_content: msg.value,
                send_id: username,
                receive_id: receiveName
            }));
            msg.value = '';
        });
    });
</script>
</body>

</html>
