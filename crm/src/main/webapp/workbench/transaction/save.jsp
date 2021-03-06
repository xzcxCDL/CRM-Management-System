<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + 	request.getServerPort() + request.getContextPath() + "/";
    Map<String,String> pMap= (Map<String, String>) application.getAttribute("Stage2Possibility");
    Set<String> possibility = pMap.keySet();
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
	<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
<script type="text/javascript">

    var json={

        <%
        for (String key : possibility){

        %>
            "<%=key%>" : <%=pMap.get(key)%>,
        <%
        }
        %>
    }
	$(function () {
		if("${param.cname}"!=""){
			$("#create-customerName").val("${param.cname}")
			$("#create-customerName").attr("disabled","disabled")
		}else {
			$("#create-customerName").attr("disabled",false);
		}
		if("${param.conname}"!=""){
			$("#create-contactsName").val("${param.conname}")
			$("#create-contactsName").attr("disabled","disabled")
			$("#create-contactsId").val("${param.conid}")
		}else {
			$("#create-contactsName").attr("disabled",false);
		}

		$(".time1").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "bottom-left"
		});

		$(".time2").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "top-left"
		});

		$("#cancelTranBtn").click(function () {
			JudingURL();
		})

		$.ajax({
			url:"workbench/transaction/getUserList.do",
			dataType:"json",
			type:"GET",
			success:function (data) {
				$.each(data,function (index,ele) {
					$("#create-owner").append(new Option(ele.name,ele.id));
				})
				$("#create-owner").val("${user.id}");
			}
		})

		$("#create-customerName").typeahead({
			source: function (query, process) {
				$.post(
						"workbench/transaction/getCustomerName.do",
						{ "name" : query },
						function (data) {
							process(data);
						},
						"json"
				);
			},
			delay: 1500
		});


		$("#saveBtn").click(function () {
			var owner=$("#create-owner").val();
			var name=$("#create-name").val();
			var expectedDate=$("#create-expectedDate").val();
			var customerName=$("#create-customerName").val();
			var stage=$("#create-stage").val();
			if(owner==null||owner==""){
				alert("?????????????????????")
				return;
			}
			if(name==null||name==""){
				alert("????????????????????????")
				return;
			}
			if(expectedDate==null||expectedDate==""){
				alert("????????????????????????")
				return;
			}
			if(customerName==null||customerName==""){
				alert("????????????????????????")
				return;
			}
			if(stage==null||stage==""){
				alert("????????????????????????")
				return;
			}
			$.ajax({
				url:"workbench/transaction/saveTran.do",
				data:{
					owner:$("#create-owner").val().trim(),
					money:$("#create-money").val().trim(),
					name:$("#create-name").val().trim(),
					expectedDate:$("#create-expectedDate").val().trim(),
					stage:$("#create-stage").val().trim(),
					type:$("#create-type").val().trim(),
					source:$("#create-source").val().trim(),
					activityId:$("#create-activityId").val().trim(),
					contactsId:$("#create-contactsId").val().trim(),
					description:$("#create-description").val().trim(),
					contactSummary:$("#create-contactSummary").val().trim(),
					nextContactTime:$("#create-nextContactTime").val().trim(),
                    customerName:$("#create-customerName").val().trim()
				},
				dataType:"json",
				type:"POST",
				success:function (data) {
					if(data.success){
						JudingURL();
					}else {
						alert("????????????!");
					}
				}
			})
		})
        
        $("#create-stage").change(function () {
            var stage=$("#create-stage").val();
            var possibility=json[stage];
            $("#create-possibility").val(possibility);
        })

		$("#openActivityBtn").click(function () {
			$("#activitySearchCondition").val("")
			$("#activitySearchBody").html("");
			$("#findMarketActivity").modal("show")
		})

		$("#activitySearchCondition").keydown(function (event) {
			if(event.keyCode=="13"){
				var html="";
				$.ajax({
					url:"workbench/transaction/getActivityByCon.do",
					data:{
						aname:$("#activitySearchCondition").val()
					},
					dataType:"json",
					type:"GET",
					success:function (data) {
						$.each(data,function (index,ele) {
							html+='<tr>';
							html+='	<td><input type="radio" name="activity" value="'+ele.id+'"/></td>';
							html+='	<td id="a'+ele.id+'">'+ele.name+'</td>';
							html+='	<td>'+ele.startDate+'</td>';
							html+='	<td>'+ele.endDate+'</td>';
							html+='	<td>'+ele.owner+'</td>';
							html+='</tr>';
						})
						$("#activitySearchBody").html(html);
					}
				})
				return false;
			}
		})

		$("#bundActivityBtn").click(function () {
			var obj=$("input[name=activity]:checked")
			$("#create-activityName").val($("#a"+obj.val()).html());
			$("#create-activityId").val(obj.val());
			$("#findMarketActivity").modal("hide");
		})

		$("#openContactsBtn").click(function () {
			$("#contactSearchCondition").val("");
			$("#contactsBody").html("");
			$("#findContacts").modal("show")
		})

		$("#contactSearchCondition").keydown(function (event) {
			var html="";
			if(event.keyCode=="13"){
				$.ajax({
					url:"workbench/transaction/getContactsByName.do",
					data:{
						name:$("#contactSearchCondition").val(),
					},
					dataType:"json",
					type:"GET",
					success:function (data) {
						$.each(data,function (index,ele) {
							html+='<tr>';
							html+='<td><input type="radio" name="contacts" value="'+ele.id+'"/></td>';
							html+='<td id="c'+ele.id+'">'+ele.fullname+'</td>';
							html+='<td>'+ele.email+'</td>';
							html+='<td>'+ele.mphone+'</td>';
							html+='</tr>';
						})
						$("#contactsBody").html(html);
					}
				})
				return false;
			}
		})

		$("#bundContactsBtn").click(function () {
			var obj=$("input[name=contacts]:checked").val();
			var fullname=$("#c"+obj).html();
			$("#create-contactsName").val(fullname);
			$("#create-contactsId").val(obj);
			$("#findContacts").modal("hide");
		})
	})


	function JudingURL() {
		var url=window.location.href;
		if(url.indexOf("workbench/customer/forwardTransave.do")>=0){
			window.location.href="workbench/customer/detail.do?id=${param.cid}";
		}else if(url.indexOf("workbench/contact/forwardTran.do")>0){
			window.location.href="workbench/contact/detail.do?id=${param.conid}";
		}
		else {
			window.location.href="workbench/transaction/index.jsp";
		}
	}
</script>
</head>
<body>

	<!-- ?????????????????? -->	
	<div class="modal fade" id="findMarketActivity" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">??</span>
					</button>
					<h4 class="modal-title">??????????????????</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" style="width: 300px;" placeholder="????????????????????????????????????????????????" id="activitySearchCondition">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable3" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>??????</td>
								<td>????????????</td>
								<td>????????????</td>
								<td>?????????</td>
							</tr>
						</thead>
						<tbody id="activitySearchBody">
							<tr>
								<td><input type="radio" name="activity"/></td>
								<td>?????????</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>
							<tr>
								<td><input type="radio" name="activity"/></td>
								<td>?????????</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>
						</tbody>
					</table>
					<div class="modal-footer">
						<button type="button" class="btn btn-default" data-dismiss="modal">??????</button>
						<button type="button" class="btn btn-primary" id="bundActivityBtn">??????</button>
					</div>
				</div>
			</div>
		</div>
	</div>

	<!-- ??????????????? -->	
	<div class="modal fade" id="findContacts" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">??</span>
					</button>
					<h4 class="modal-title">???????????????</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" style="width: 300px;" placeholder="?????????????????????????????????????????????" id="contactSearchCondition">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>??????</td>
								<td>??????</td>
								<td>??????</td>
							</tr>
						</thead>
						<tbody id="contactsBody">
							<tr>
								<td><input type="radio" name="activity"/></td>
								<td>??????</td>
								<td>lisi@bjpowernode.com</td>
								<td>12345678901</td>
							</tr>
							<tr>
								<td><input type="radio" name="activity"/></td>
								<td>??????</td>
								<td>lisi@bjpowernode.com</td>
								<td>12345678901</td>
							</tr>
						</tbody>
					</table>
					<div class="modal-footer">
						<button type="button" class="btn btn-default" data-dismiss="modal">??????</button>
						<button type="button" class="btn btn-primary" id="bundContactsBtn">??????</button>
					</div>
				</div>
			</div>
		</div>
	</div>
	
	
	<div style="position:  relative; left: 30px;">
		<h3>????????????</h3>
	  	<div style="position: relative; top: -40px; left: 70%;">
			<button type="button" class="btn btn-primary" id="saveBtn">??????</button>
			<button type="button" class="btn btn-default" id="cancelTranBtn">??????</button>
		</div>
		<hr style="position: relative; top: -40px;">
	</div>
	<form class="form-horizontal" role="form" style="position: relative; top: -30px;">
		<div class="form-group">
			<label for="create-owner" class="col-sm-2 control-label">?????????<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-owner">

				</select>
			</div>
			<label for="create-money" class="col-sm-2 control-label">??????</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-money">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-name" class="col-sm-2 control-label">??????<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-name">
			</div>
			<label for="create-expectedDate" class="col-sm-2 control-label">??????????????????<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control time1" id="create-expectedDate">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-customerName" class="col-sm-2 control-label">????????????<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-customerName" placeholder="???????????????????????????????????????????????????">
			</div>
			<label for="create-stage" class="col-sm-2 control-label">??????<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
			  <select class="form-control" id="create-stage">
			  	<option></option>
				  <c:forEach items="${applicationScope.stageList}" var="s">
					  <option value="${s.value}">${s.text}</option>
				  </c:forEach>
			  </select>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-type" class="col-sm-2 control-label">??????</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-type">
				  <option></option>
					<c:forEach items="${applicationScope.transactionTypeList}" var="t">
						<option value="${t.value}">${t.text}</option>
					</c:forEach>
				</select>
			</div>
			<label for="create-possibility" class="col-sm-2 control-label">?????????</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-possibility" disabled>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-source" class="col-sm-2 control-label">??????</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-source">
				  <option></option>
					<c:forEach items="${applicationScope.sourceList}" var="s">
						<option value="${s.value}">${s.text}</option>
					</c:forEach>
				</select>
			</div>
			<label for="create-activityName" class="col-sm-2 control-label">???????????????&nbsp;&nbsp;<a href="javascript:void(0);" data-toggle="modal" id="openActivityBtn"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-activityName" disabled>
				<input type="hidden" id="create-activityId">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactsName" class="col-sm-2 control-label">???????????????&nbsp;&nbsp;<a href="javascript:void(0);" data-toggle="modal" id="openContactsBtn"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-contactsName" disabled>
				<input type="hidden" id="create-contactsId">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-description" class="col-sm-2 control-label">??????</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-description"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactSummary" class="col-sm-2 control-label">????????????</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-nextContactTime" class="col-sm-2 control-label">??????????????????</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control time2" id="create-nextContactTime">
			</div>
		</div>
		
	</form>
</body>
</html>