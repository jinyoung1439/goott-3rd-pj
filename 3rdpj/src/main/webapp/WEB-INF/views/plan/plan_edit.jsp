<%--
  Created by IntelliJ IDEA.
  User: 길영준
  Date: 2023-04-05
  Time: 오전 10:47
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>
<head>
    <title>Title</title>
</head>
<body>

<p>기존 이미지 : </p>
<c:forEach var="img" items="${data.p_img}">
    <img src="${img}" height="200px" width="200px" style="border: 1px solid red;">
</c:forEach>

<form name="create" method="POST" action="/plan/list/edit?idx=${data.plan_idx}&auth=${data.user_id}" enctype="multipart/form-data">
<%--    <input type="hidden" name="_method" value="put"/>--%>
    <label for="title">제목
        <input id="title" type="text" name="plan_title" value="${data.plan_title}">
    </label>
    <br>
    <label for="start_date">여행시작날짜</label>
    <input type="date" id="start_date" name="start_date" value="${data.start_date}">
    <br>
    <label for="finish_date">여행종료날짜</label>
    <input type="date" id="finish_date" name="end_date" value="${data.end_date}">
    <br>
    <label for="price">가격</label>
    <input type="number" id="price" name="price" value="${data.price}">
    <br>
    <label for="plan_detail">내용</label>
    <textarea id="plan_detail" name="plan_detail" placeholder="${data.plan_detail}"></textarea>
    <p>변경할 이미지 : </p>
    <input type="file" name="files[]" id="file-input" onchange="previewFile()" multiple/>
    <c:if test="${data.user_id == sessionScope.user_id}">
        <button type="submit">수정</button>
        <button class="button" id="delete" type="button">삭제</button>
    </c:if>
</form>
    <div id="preview"></div>

<script>
    /**
     * 이미지 미리보기
     * @returns {Promise<void>}
     */
    async function previewFile() {
        var preview = document.getElementById("preview"); // 미리보기 띄울 div
        var files = document.getElementById('file-input').files; // img 파일들
        var cnt = 0; // 이미지 갯수
        preview.innerHTML = ''; // 미리보기 초기화

        for (const file of files) {  // 반복문 한번 반복 때마다 이미지 1개씩 view
            await new Promise((resolve, reject) => {
                var reader = new FileReader(); // FileReader 객체를 생성
                reader.onload = function() { // 파일 로드가 성공시 호출 될 함수
                    var img = document.createElement("img"); // img 생성
                    img.src = reader.result; // 로드된 파일을 img 요소의 src에 할당
                    img.onload = () => { // 이미지 로드가 완료되면 이 함수가 호출
                        preview.appendChild(img); // preview 요소의 자식 노드로 img 추가
                        resolve(); // 결과 호출
                        cnt++ // 이미지 갯수 더하기
                        if(cnt == files.length){
                            $('#upload-btn').prop('disabled', false); // 이미지 파일 올리면 저장버튼 활성화
                        }
                        else if(cnt != files.length){
                            $('#upload-btn').prop('disabled', true); // 이미지 파일 취소 할 경우 다시 비활성화
                        }
                    }
                };
                reader.onerror = function() {
                    reject(new Error('파일 로드 실패'));
                };
                reader.readAsDataURL(file);
            });
        }
    }
    /**
     * 이미지 업로드 조건
     * @type {RegExp}
     */
    let regex = new RegExp("(.*?)\.(jpg|png)$");         // jpg,png 파일만 허용
    let maxSize = 41943040;                              // file 제한 용량 40MB

    $("input[type='file']").on("change", function(e){
        let fileInput = document.querySelector("#fileItem");
        let fileList = fileInput.files;
        let fileObj = fileList[0];

        if(!fileCheck(fileObj.name, fileObj.size)) return false;
        alert("통과")
    });

    // 이미지 체크 로직
    function fileCheck(fileName, fileSize){
        if(fileSize >= maxSize){
            alert("파일 사이즈 초과 : 최대 40MB");
            return false;
        }
        if(!regex.test(fileName)){
            alert("해당 종류의 파일은 업로드할 수 없습니다. 업로드 가능한 file : jpg, png");
            return false;
        }
    }
</script>
</body>
</html>
