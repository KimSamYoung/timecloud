<%@ page import="com.twobrain.common.util.Html" %>
<%@ page import="com.twobrain.common.core.QueryHandler" %>
<%@ page import="com.twobrain.common.core.DataSet" %>
<%@ page import="org.apache.commons.lang3.StringUtils" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../common/include/incInit.jspf" %>
<%@ include file="../common/include/incSession.jspf" %><%
	DataSet ds = QueryHandler.executeQuery("SELECT_USER_TEAM_LIST", new String[]{USER_IDX, DOMAIN_IDX}) ;

    final String thead = "<thead><tr><th>#</th><th>팀</th><th>팀원수</th><th>팀장</th><th>lastModified</th><th>최초등록</th><th>상태</th><th>&nbsp;</th></tr></thead>";
    String nodata = Html.tr(Html.td("데이터가 없습니다.", "style='text-align:center' colspan=8"));

    StringBuffer sbListOff = new StringBuffer(thead);
    StringBuffer sbListOn = new StringBuffer(thead);
    String tabOff = "<small class='label label-important'>OFF</small>" ;
    String tabOn = "<small class='label label-warning'>ON</small>" ;
    int offcnt = 0, oncnt = 0;
    String trash = "";
	if(ds != null) {
		TeamInfo team = null ;
        String row ="", status="",idx="", n_owner_idx = "", owner_name = "";
 	 	while (ds.next()) {
 	 		team = new TeamInfo(ds) ;
            idx = team.getIdx();
            n_owner_idx = team.getOwnerIdx();
            owner_name = team.getOwnerName();

            row = Html.td(idx)
                +Html.td(Html.a(team.getName(),String.format("href='view.jsp?team_idx=%s'",idx)))
                +Html.td(team.getUserCnt())
                +Html.td(getProfileImage(n_owner_idx)+Html.span(" "+owner_name))
                +Html.td(team.getEdtDatetime())
                +Html.td(team.getRegDatetime());

            trash = Html.td(Html.a(Html.Icon.TRASH,"href='javascript:deleteItem("+idx+");'"));
            if( team.isOFF() ){
                offcnt++;

                if( StringUtils.equals(USER_IDX,n_owner_idx) )  // 내가 팀장인 것만 콘트롤
                    status = "<input type='button' class='btn btn-mini btn-danger' value='Off' onClick='javascript:switchOn("
                            + idx + ")' />";

                row+=Html.td(status);
                row += trash;
                sbListOff.append(Html.tr(row));
            }
 	 		else{ // 정상일때 누르면 끄게 됨
                oncnt ++;
                if( StringUtils.equals(USER_IDX,n_owner_idx) ) // 내가 팀장인 것만 콘트롤
                    status = "<input type='button' class='btn btn-mini btn-warning' value='On' onClick='javascript:switchOff("
                            + idx + ")' />";
                row+=Html.td(status);
                row += trash;
                sbListOn.append(Html.tr(row));
            }
		}

	}

    if(offcnt == 0)sbListOff.append(nodata);
    if(oncnt == 0)sbListOn.append(nodata);

    String listOn = Html.table(sbListOn.toString(),"class='table table-bordered table-hover'");
    String listOff = Html.table(sbListOff.toString(),"class='table table-bordered table-hover'");

%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>User List</title>
<%@ include file="../common/include/incHead.jspf" %>
<script type="text/javascript">
    function switchOn(idx) {
        if(confirm("팀을 활성화합니다.\n계속하시겠습니까?")){
            location.replace("toggle.jsp?toggle=on&team_idx="+idx) ;
        }

        return ;
    }

    function switchOff(idx) { // -- task termination
        if(confirm("팀을 비활성화합니다.\n계속하시겠습니까?")){
            location.replace("toggle.jsp?toggle=off&team_idx="+idx) ;
        }

        return ;
    }

    function deleteItem(idx) { // -- task termination
        if(confirm("삭제하시겠습니까?")){
            location.replace("delete.jsp?team_idx="+idx) ;
        }

        return ;
    }
</script>
</head>
<body>
<div class="row-fluid">
	<div class='span10'><%@ include file="../menuGlobal.jsp" %>
		<div class="row-fluid">
			<div class='span2 vertNav'><%=getVertNav(req, oUserSession) %></div>
			<div class='span10 all'>
<%-- --%>
                <table width="100%">
                    <tr><td><h3>My Team List</h3></td>
                    <td align="right">
                        <!-- Button trigger modal -->
                        <button class="btn btn-primary btn-lg text-right" data-toggle="modal" data-target="#myModal">팀 등록</button>
                    </td></tr>
                </table>

                <%-- Modal --%>
                <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                                <h4 class="modal-title" id="myModalLabel">팀 등록</h4>
                            </div>
                            <div class="modal-body">
                                <form id='f1' method='post' action='insert.jsp'>
                                    <table>
                                        <tr><td>팀 명 : </td><td><input type="text" name="team_name" /></td></tr>
                                    </table>
                                </form>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                                <button type="button" class="btn btn-primary" onclick="javascript:document.getElementById('f1').submit();" >Save changes</button>
                            </div>
                        </div>
                    </div>
                </div>
                <ul class="nav nav-tabs">
                    <li class=active><a href="#tab1" data-toggle="tab"><%=tabOn %></a></li>
                    <li><a href="#tab2" data-toggle="tab"><%=tabOff %></a></li>
                </ul><br/>
                <div class='tab-content'>
                    <div class='tab-pane active' id='tab1'><%=listOn %></div>
                    <div class='tab-pane' id='tab2'><%=listOff %></div>
                </div>
<%-- --%>
			</div>
		</div>
	</div>
	<%=getNotification(oUserSession, "span2 noti") %>		
</div>
</body>
</html><%!
class TeamInfo {
	final private String n_idx ;
    final private String v_name ;
    final private String v_reg_datetime ;
    final private String v_edt_datetime ;
    final private String c_off_yn ;
    final private String n_user_cnt;
    final private String n_owner_idx;
    final private String owner_name;

	TeamInfo (DataSet ds) {
		this.n_idx = ds.getString(1) ;
		this.v_name = ds.getString(2) ;
		this.c_off_yn = ds.getString(3) ;
		this.v_reg_datetime = ds.getString(4) ;
		this.v_edt_datetime = ds.getString(5) ;
        this.n_user_cnt = ds.getString(6);
        this.n_owner_idx = ds.getString(7);
        this.owner_name = ds.getString(8);
	}
	public boolean isOFF(){
		return "Y".equals(c_off_yn) ;
	}
    public String getName() {
        return v_name;
    }
    public String getRegDatetime(){return v_reg_datetime;}
    public String getEdtDatetime(){return v_edt_datetime;}
    public String getOffYn(){
        return c_off_yn;
    }
    public String getIdx(){
        return n_idx;
    }
    public String getUserCnt(){
        return n_user_cnt;
    }
    public String getOwnerIdx(){ return n_owner_idx;}
    public String getOwnerName(){ return owner_name;}
}
%>