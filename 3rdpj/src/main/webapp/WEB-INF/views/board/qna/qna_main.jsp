<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/views/common/layout.jsp" %>
<%@ include file="/WEB-INF/views/common/modal_right.jsp" %> 
	
<main class="qna">
      <hgroup class="qna__title">
        <h1>Q&A</h1>
      </hgroup>
      <section class="qna__grid">
        <article class="qna__card">
          <hgroup class="qna__card--title">
            <h1>공지사항</h1>
          </hgroup>
          <ul class="qna__card--list">
            <c:forEach items="${data_n}" var="list" varStatus="status">
            	<c:if test="${status.count <= 5}">
            		<li><input type="hidden" name="qna_idx" value="${list.qna_idx}"></li>
            		<li><a class="link__detail">${list.qna_title}</a></li>
            	</c:if>
            </c:forEach>
        		<li><a href="/qna/list_N">더보기</a></li>
          </ul>
        </article>
        <article class="qna__card">
          <hgroup class="qna__card--title">
            <h1>자주 찾는 질문</h1>
          </hgroup>
          <ul class="qna__card--list">
            <c:forEach items="${data_q}" var="list" varStatus="status">
            	<c:if test="${status.count <= 5}">
            		<li><input type="hidden" name="qna_idx" value="${list.qna_idx}"></li>
            		<li><a class="link__detail">${list.qna_title}</a></li>
            	</c:if>
            </c:forEach>
        		<li><a href="/qna/list_Q">더보기</a></li>
          </ul>
        </article>
      </section>
      <button onclick="location.href='/qna/list_R'">신고게시판</button>
      <button onclick="location.href='/qna/list_U'">이용게시판</button>
    </main>
    
	<script src="/resources/js/common/layout.js"></script>
	<script src="/resources/js/common/modal_right.js"></script>
    <script>
		const CATEGORY_IDX = 3;
		$(function() {
	        $('.link__detail').click(function(e) {
	            const idx = e.target.parentElement.previousElementSibling.children[0]
	            const arrUrl = document.location.href.split("/")
	            location.href="/"+arrUrl[CATEGORY_IDX]+"/detail/"+idx.value
	        })
	    })
	</script>