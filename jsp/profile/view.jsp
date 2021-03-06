<%@ page import="java.io.File" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/include/incInit.jspf" %>
<%@ include file="../common/include/incSession.jspf" %>
<%
    response.setHeader("Cache-Control", "no-cache");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    final String pUserIdx = req.getParam("user_idx", "" + oUserSession.getUserIdx());
    DataSet ds = QueryHandler.executeQuery("SELECT_USER_INFO", new String[]{pUserIdx});
    UserInfo user = null;
    if (ds != null) {
        if (ds.next()) {
            user = new UserInfo(ds);
        }
    }

    if (user == null) {
        out.println("Fail to access .");
        return;
    }

    final String email = user.getEmail();
    final String name = user.getName();
    final String photo = getProfileImage(USER_IDX);
    final String tel = user.getTel();
    final String noti_email = user.getNotiEmail();
    String regdate = user.getRegDateTime();
    String upddate = user.getEdtDateTime();
    regdate = DateTime.convertDateFormat(regdate);
    upddate = DateTime.convertDateFormat(upddate);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>User List</title>
    <%@ include file="../common/include/incHead.jspf" %>
    <%@ include file="../common/include/incFileUpload.jspf" %>

    <%--<meta http-equiv="cache-control" content="No-Cache">--%>
    <%--<META HTTP-EQUIV="expires" content="0">--%>
    <%--<meta http-equiv="pragma" content="no-cache">--%>

    <script type="text/javascript">
        $(document).ready(function () {
        });

        function check() {
            var f = document.getElementById('f1');
            var uname = f.user_name;
            if (uname.value.length < 2) {
                alert("이름을 확인해 주세요.");
                uname.focus();
                return;
            }

            var p1 = f.user_passwd;
            if (p1.value == '') {
                alert("비밀번호를 입력해 주세요");
                p1.focus();
                return;
            }
            f.submit();
        }

        function check2() {
            var f = document.getElementById('f2');
            var p0 = f.user_passwd_now;
            var p1 = f.user_passwd_new;
            var p2 = f.user_passwd_new2;
            if (p0.value == '') {
                alert("현재 비밀번호를 입력해 주세요");
                p0.focus();
                return;
            }
            if (p1.value == '') {
                alert("변경할 비밀번호를 입력해 주세요");
                p1.focus();
                return;
            }
            if (p1.value.length < 4) {
                alert("비밀번호는 4글자 이상입니다.");
                p1.focus();
                return;
            }
            if (p0.value == p1.value) {
                alert("입력하신 현재 비밀번호와 변경할 비밀번호가 동일합니다.");
                p1.focus();
                return;
            }
            if (p1.value != p2.value) {
                alert("새로운 비밀번호가 서로 일치하지 않습니다.");
                p1.value = "";
                p2.value = "";
                p1.focus();
                return;
            }

            f.submit();
        }
    </script>
</head>
<body>
<div class="row-fluid">
    <div class='span12'>
        <%--<%@ include file="../menuGlobal.jsp" %>--%>
        <div class="row-fluid">
            <%--<div class='span2 vertNav'><%=getVertNav(req, oUserSession) %></div>--%>
            <div class='span12 all'>
                <table class="table table-bordered">
                    <tr>
                        <th width="80px">이메일</th>
                        <td><%=email%>
                        </td>
                    </tr>
                    <tr>
                        <th>이름</th>
                        <td><%=name%>
                        </td>
                    </tr>
                    <tr>
                        <th>사진</th>
                        <td>
                            <div><%=photo%><br/>
                                <%
                                    String uploadPath = Config.getProperty("init", "FILE_UPLOAD_BASE_REPOSITORY") + "/profile/";
                                    File file = new File(uploadPath + String.format("%s", USER_IDX));
                                    if (file.exists()) {
                                %>
                                <%--<iframe scrolling="no" frameborder="0" style="width:100px;height:100px"--%>
                                        <%--src="<%=getProfileImageUrl(Integer.parseInt(USER_IDX))%>?1"></iframe>--%>
                                <button class="btn" onclick="javascript:location.href='thumbnail.jsp';">사진변경</button>
                                <%
                                } else {
                                %>
                                <button class="btn" onclick="javascript:location.href='thumbnail.jsp';">사진등록</button>
                                &nbsp;<i class="fa fa-info"></i> 팀원들이 잘 알아볼 수 있게 사진을 등록해주세요.
                                <%
                                    }
                                %>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th>연락처</th>
                        <td><%=tel%>
                        </td>
                    </tr>
                    <tr>
                        <th>보조 이메일</th>
                        <td><%=noti_email%>
                        </td>
                    </tr>
                    <tr>
                        <th>등록일</th>
                        <td><%=regdate%>
                        </td>
                    </tr>
                    <tr>
                        <th>갱신일</th>
                        <td><%=upddate%>
                        </td>
                    </tr>
                </table>
                <div class="form-actions">
                    <button type="button" class="btn btn-primary" onclick="javascript:profile();">프로필 수정</button>
                    <button type="button" class="btn" onclick="javascript:password();">비밀번호 변경</button>
                </div>
                <%-- --%>
            </div>
        </div>
    </div>
    <%--<%=getNotification(oUserSession, "span4 noti") %>--%>
</div>
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
     aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal"><span
                        aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                <h4 class="modal-title" id="myModalLabel"></h4>
            </div>
            <div class="modal-body"></div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                <button id="btnSubmit" type="button" class="btn btn-primary">Save
                    changes
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    function password() {
        $('#myModal h4.modal-title').text("비밀번호 변경하기");
        $('#myModal div.modal-body').html($("#template li:eq(1)").html());
        $("#btnSubmit").unbind("click");
        $("#btnSubmit").bind("click",function(){
            check2();
        });
        $('#myModal').modal('show');
    }
    function profile() {
        $('#myModal h4.modal-title').text("Profile 수정하기");
        $('#myModal div.modal-body').html($("#template li:eq(0)").html());
        $("#btnSubmit").unbind("click");
        $("#btnSubmit").bind("click",function(){
            check();
        });
        $('#myModal').modal('show');
    }
</script>
<div id='template' style="display:none">
    <ul>
        <li>
            <%--Profile Form--%>
            <form id='f1' method='post' action='update.jsp'>
                <table>
                    <tr>
                        <th>이메일</th>
                        <td><%=email%>
                        </td>
                    </tr>
                    <tr>
                        <th>이름</th>
                        <td><input type="text" name="user_name" value="<%=name%>"/></td>
                    </tr>
                    <tr>
                        <th>사진</th>
                        <td><%=photo %>
                        </td>
                    </tr>
                    <tr>
                        <th>연락처</th>
                        <td><input type="text" name="user_tel" value="<%=tel%>"/></td>
                    </tr>
                    <tr>
                        <th>보조 이메일</th>
                        <td><input type="text" name="user_noti_email" value="<%=noti_email%>"/></td>
                    </tr>
                    <tr>
                        <th>비밀번호</th>
                        <td><input type="password" name="user_passwd" value=""/>
                            <br/>* 변경을 원하시면 비밀번호를 입력해 주세요
                        </td>
                    </tr>
                </table>
            </form>
        </li>
        <li>
            <%--Password Form--%>
            <form id='f2' method='post' action='password.jsp'>
                <table>
                    <tr>
                        <th>현재 비밀번호</th>
                        <td><input type="password" name="user_passwd_now" value=""/></td>
                    </tr>
                    <tr>
                        <th>새로운 비밀번호</th>
                        <td><input type="password" name="user_passwd_new" value=""/></td>
                    </tr>
                    <tr>
                        <th>새로운 비밀번호(확인)</th>
                        <td><input type="password" name="user_passwd_new2" value=""/></td>
                    </tr>
                </table>
            </form>
        </li>
    </ul>
</div>

</body>
</html>
<%!

    class UserInfo {    // -- TODO - IncInit의 User와 충돌
        String n_idx;
        String v_email;
        String v_name;
        String v_reg_datetime; // 등록일
        String v_edt_datetime; // 최근 갱신일
        String c_off_yn;
        String n_profile_image_idx;
        String v_tel;
        String v_noti_email;

        public UserInfo(DataSet ds) {
            this.n_idx = ds.getString("N_IDX");
            this.v_email = ds.getString("V_EMAIL");
            this.v_name = ds.getString("V_NAME");
            this.c_off_yn = ds.getString("C_OFF_YN");
            this.v_reg_datetime = ds.getString("V_REG_DATETIME");
            this.v_edt_datetime = ds.getString("V_EDT_DATETIME");
            this.v_tel = ds.getString("V_TEL");
            this.v_noti_email = ds.getString("V_NOTI_EMAIL");
        }

        public boolean isOFF() {
            return "Y".equals(c_off_yn);
        }

        public String getEmail() {
            return v_email;
        }

        public String getName() {
            return v_name;
        }

        public String get() {
            // -- task_idx를 경로에 노출하지 않는 방법은?
            return "<a href='userInfo.jsp?user_idx=" + n_idx + "'>" + v_email + "</a>";
        }

        public String getTel() {
            return v_tel;
        }

        public String getProfileImageIdx() {
            return n_profile_image_idx;
        }

        public String getProfileImage() {
            if (n_profile_image_idx == null || n_profile_image_idx.equals("")) {
                return "";
            } else {
                return String.format("<img src='/jsp/common/fileupload/fileAction.jsp?pAction=GetThumbNail&pFileIdx=%s'/>", n_profile_image_idx);
            }
        }

        public String getNotiEmail() {
            return v_noti_email;
        }

        public String getRegDateTime() {
            return v_reg_datetime;
        }

        public String getEdtDateTime() {
            return v_edt_datetime;
        }
    }
%>