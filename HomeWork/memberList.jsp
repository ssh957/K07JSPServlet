<%@page import="homework.MembershipDAO"%>
<%@page import="homework.MembershipDTO"%>
<%@page import="common.BoardConfig"%>
<%@page import="utils.BoardPage"%>
<%@page import="model1.board.BoardDTO"%>
<%@page import="java.util.List"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="model1.board.BoardDAO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% 
//application내장객체를 인수로 DAO객체를 생성한다.(DB연결)
MembershipDAO dao = new MembershipDAO(application);

//파라미터를 저장하기 위해 Map컬렉션 생성
Map<String, Object> param = new HashMap<String, Object>();

//검색에 대한 파라미터를 받아서 변수에 저장
String searchField = request.getParameter("searchField");//검색할 필드명
String searchWord = request.getParameter("searchWord");//검색어

//검색 파라미터 추가 위한 변수
String queryStr = "";

//사용자가 검색을 했다면...
if(searchWord!=null){
	//검색필드와 검색어를 Map에 추가한다. 
	param.put("searchField", searchField);
	param.put("searchWord", searchWord);
	
	//검색 파라미터 추가하기
	queryStr = "&searchField="+searchField+"&searchWord="+searchWord;
}
//게시물의 전체 갯수를 카운트하기 위한 메소드 호출
int totalCount = dao.selectCount(param);

/**** 페이지처리 start ***/
int pageSize = BoardConfig.PAGE_PER_SIZE;//한페이지에 출력할 게시물의 갯수
int blockPage = BoardConfig.PAGE_PER_BLOCK;//한 블럭당 출력할 페이지번호의 갯수
int totalPage = (int)Math.ceil((double)totalCount/pageSize);//전체 페이지 수 계산
int pageNum = 1;//목록 첫 진입시에는 무조건 1페이지로 지정
//만약 파라미터로 전달된 페이지번호가 있다면..
String pageTemp = request.getParameter("pageNum");
if(pageTemp!=null && !pageTemp.equals(""))
	pageNum = Integer.parseInt(pageTemp);//해당 번호로 페이지번호를 지정한다.
//목록을 페이지별로 구분하기 위해 between에 사용할 값 계산
int start = (pageNum-1) * pageSize + 1;
int end = pageNum * pageSize;
//계산된 값은 Map컬렉션에 저장
param.put("start", start);
param.put("end", end);
/***페이지처리 end ***/

//목록에 실제 출력할 레코드를 얻어오기 위한 메소드 호출
List<MembershipDTO> memberLists = dao.memberList(param);
//자원해제
dao.close();
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원제 게시판</title>
</head>
<body>
	<h2>목록보기(List)</h2>
	<%@ include file="../common/CommonLink.jsp" %>
	
	<!-- 검색폼 : 제목과 내용을 통해 검색할 수 있다. -->
	<form method="get">
	<table border="1" width="90%">
	<tr>
		<td align="center">
			<select name="searchField">
				<option value="title">제목</option>
				<option value="content">내용</option>
			</select>
			<input type="text" name="searchWord" />
			<input type="submit" value="검색하기" />
		</td>
	</tr>	
	</table>	
	</form>
	
	<!-- 목록 출력을 위한 테이블 -->
	<table border="1" width="90%">
		<tr>
			<th width="10%">번호</th>
			<th width="20%">아이디</th>
			<th width="20%">핸드폰번호</th>
			<th width="20%">이메일</th>
			<th width="20%">가입날짜</th>
		</tr>
<%
if(memberLists.isEmpty()){
	//컬렉션에 저장된 데이터가 없다면...
%>
		<tr>
			<td colspan="5" align="center">
				등록된 게시물이 없습니다^^*
			</td>
		</tr>
<%
}
else{
	//컬렉션에 저장된 데이터가 있다면 해당 내용을 반복하여 출력한다.
	int vNum = 0;//목록의 가상번호로 사용
	int countNum = 0;	
	//List컬렉션에 저장된 갯수만큼 반복하기 위해 확장for문 사용
	for(MembershipDTO dto : memberLists)
	{
		//현재 페이지 번호를 적용해서 가상번호 계산
		vNum = totalCount - (((pageNum-1) * pageSize) + countNum++);
		
		//getter()를 통해 출력한다.
%>
<!-- 			<td align="left"> -->
<%-- 				<a href="View.jsp?num=<%=dto.getId()%><%=queryStr %>"><%=dto.getTitle()%></a> --%>
<%-- 				<a href="View.jsp?num=<%=dto.getId()%><%=queryStr %>"></a> --%>
<!-- 			</td> -->
		<tr align="center">
			<td><%=vNum%></td>
			<td align="center">
				<a href="memberView.jsp?id=<%=dto.getId() %><%=queryStr %>"><%=dto.getId()%></a>
			</td>
			<td align="center"><%=dto.getPhone()%></td> 
			<td align="center"><%=dto.getEmail()%></td>
			<td align="center"><%=dto.getRegistdate()%></td>  
		</tr>
<%
	}  
}
%>
	</table>
	<table border="1" width="90%">
		<!-- <tr align="right">			
			<td><button type="button" onclick="location.href='Write.jsp';">
				글쓰기</button></td>
		</tr> -->
		<tr align="center">
			<td>
				<!-- 페이지 번호 링크에 검색 파라미터가 없는경우 -->
				<%--=BoardPage.pagingStr(totalCount, pageSize, blockPage, 
						pageNum, request.getRequestURI())--%>	
				
				<!-- 검색 파라미터를 넘겨주는 경우 -->
				<%=BoardPage.pagingImg(totalCount, pageSize, blockPage, 
						pageNum, request.getRequestURI())%>							 
			</td>
		</tr>
	</table>	
</body>
</html>


