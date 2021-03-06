<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="./common/include/incInit.jspf" %>
<%@ include file="./common/include/incSession.jspf" %>
<%@ include file="./common/include/incTaskView.jspf" %>
<%
    String isModal = req.getParam("modal", "N");

    _toolTabNo = 1;
    // -- 태스크 정보 출력
    DataSet ds = null;

    // -- 달력에 액티비티 출력
    ds = QueryHandler.executeQuery("SELECT_TASK_ALL_ACTIVITY_LIST", TASK_IDX); // -- ("SELECT_ACTIVITY_LIST", new String[]{""+TASK_IDX, ""+currentTask.getOwnerIdx()}) ;
    String sLastEndDateTime = "";
    String events = "";
    if (ds != null && ds.size() > 0) {
        Activity activity = null;

        long lastEndDateTime = 0;

        while (ds.next()) {
            activity = new Activity(ds, TASK_IDX);

            if (lastEndDateTime < activity.getEndDateTime()) {
                lastEndDateTime = activity.getEndDateTime();
            }

            events += activity.get();
        }

        // 이후에 DB에서 한번에 조회하는것도 괜찮을듯..
        sLastEndDateTime = Long.toString(lastEndDateTime);
        sLastEndDateTime = sLastEndDateTime.substring(0, 4) + "," + (Integer.parseInt(sLastEndDateTime.substring(4, 6)) - 1) + "," + sLastEndDateTime.substring(6, 8);

        ds = null;
    }

    final boolean IS_TASK_OWNER = (currentTask.getOwnerIdx() == oUserSession.getUserIdx());
    final boolean IS_TASK_ON = (!currentTask.isOff() && !currentTask.isDel());

    boolean readonly = (isAll || !IS_TASK_OWNER || !IS_TASK_ON); // 내 태스크이고, 전체모드가 아니고, 태스크가 활성 상태이다.

    UserComponent component = UserComponent.getInstance(USER_IDX, DOMAIN_IDX);
    String userCombo = component.getUserCombo();
    String userCheckbox = component.getUserCheckBox();
%><!DOCTYPE html>
<html lang="en">
<head>
<title>Communication / Activity Tools</title>
<%@ include file="./common/include/incHead.jspf" %>
<%--fullcalendar--%>
<link href="<%=CSS_PATH%>/fullcalendar.css" rel="stylesheet">
<link href="<%=CSS_PATH%>/fullcalendar.print.css" rel="stylesheet" media="print">
<script src="<%=JS_PATH%>/fullcalendar.js"></script>
<%-- 버전문제있음 - fullcalendar-2.0.2--%>
<%--<link href="/test/fullcalendar-2.0.2/fullcalendar.css" rel="stylesheet">--%>
<%--<link href="/test/fullcalendar-2.0.2/fullcalendar.print.css" rel="stylesheet" media="print">--%>
<%--<script src="/test/fullcalendar-2.0.2/lib/moment.min.js"></script>--%>
<%--<script src="/test/fullcalendar-2.0.2/fullcalendar.min.js"></script>--%>
<%--jquery validator--%>
<script src="/html/assets/jquery.validate.min.js"></script>
<script src="/html/assets/additional-methods.min.js"></script>
<%--color picker--%>
<script src="/html/assets/bootstrap-clockpicker.min.js"></script>
<link href="/html/assets/bootstrap-clockpicker.min.css" rel="stylesheet">

<script type="text/javascript">
<%	if(!readonly) {	%>
Date.prototype.format = function (f) {
    if (!this.valueOf()) return " ";

    var weekName = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"];
    var d = this;

    return f.replace(/(yyyy|yy|MM|dd|E|hh|mm|ss|a\/p)/gi, function ($1) {
        switch ($1) {
            case "yyyy":
                return d.getFullYear();
            case "yy":
                return (d.getFullYear() % 1000).zf(2);
            case "MM":
                return (d.getMonth() + 1).zf(2);
            case "dd":
                return d.getDate().zf(2);
            case "E":
                return weekName[d.getDay()];
            case "HH":
                return d.getHours().zf(2);
            case "hh":
                return ((h = d.getHours() % 12) ? h : 12).zf(2);
            case "mm":
                return d.getMinutes().zf(2);
            case "ss":
                return d.getSeconds().zf(2);
            case "a/p":
                return d.getHours() < 12 ? "오전" : "오후";
            default:
                return $1;
        }
    });
};

String.prototype.string = function (len) {
    var s = '', i = 0;
    while (i++ < len) {
        s += this;
    }
    return s;
};
String.prototype.zf = function (len) {
    return "0".string(len - this.length) + this;
};
Number.prototype.zf = function (len) {
    return this.toString().zf(len);
};

var calendar;

$(document).ready(function () {
    var wrapHeight = $(document).height();
    var date = new Date();
    var d = date.getDate();
    var m = date.getMonth();
    var y = date.getFullYear();

    calendar = $('#calendar').fullCalendar({
        header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month,agendaWeek,agendaDay'
        },
        eventClick: function (calEvent, jsEvent, view) { // activity clicked
            console.log(calEvent);
            $("#register h3#registerLabel").text("일정 수정");
            $("#register #activityIdx").val(calEvent.idx);
            var start_date = convertDate(calEvent.start);
            var start_time = convertTime(calEvent.start);
            $("#register #startDate").val(start_date);
            $("#register #startTime").val(start_time);

            var end_date = '';
            var end_time = '';
            if (calEvent.end != null) {
                end_date = convertDate(calEvent.end);
                end_time = convertTime(calEvent.end);
            }
            else {
                end_date = start_date;
                end_time = start_time;
            }

            $("#register #endDate").val(end_date);
            $("#register #endTime").val(end_time);

            $("#register #desc").val(calEvent.title);

            modalOpen();
//            $(this).css('border-color', 'red');
        },
        eventMouseover: function (calEvent, jsEvent, view) {
            $(this).css('border-color', '#999');
        },
        eventMouseout: function (calEvent, jsEvent, view) {
            $(this).css('border-color', '#bfbfbf');
        },
        eventDragStart: function (calEvent, jsEvent, ui, view) {
        },
        eventDragStop: function (calEvent, jsEvent, ui, view) {
        },
        eventDrop: function (calEvent, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view) {
            onChange(calEvent, revertFunc);
        },
        eventResizeStart: function (calEvent, jsEvent, ui, view) {
        },
        eventResizeStop: function (calEvent, jsEvent, ui, view) {
        },
        eventResize: function (calEvent, dayDelta, minuteDelta, revertFunc, jsEvent, ui, view) {
            onChange(calEvent, revertFunc);
        },
        selectable: true,
        selectHelper: true,
        select: function (start, end, allDay) {
            modalInit();
            $("#startDate").val(convertDate(start));
            $("#endDate").val(convertDate(end));
            $("#register h3#registerLabel").text("일정 등록");
            modalOpen();
        },

        editable: true,
        events: [ <%=events%> ]
    });

    var _date = new Date(<%=sLastEndDateTime%>);

    if (_date < new Date()) {
        $('#calendar').fullCalendar('gotoDate', _date);
    }

    $('.fc-event').draggable();

    // modal form setting
//    $('.clockpicker').clockpicker();
    $('#startTime').clockpicker({
        autoclose: true,
        beforeShow: function() {
            $("span.clockpicker-span-hours").text("");
        },
        afterHourSelect: function() {
            var el = $("#startTime");
            var min = "00";
            if(el.val().indexOf(":")>0){
                var arr = el.val().split(":");
                min = arr[1];
            }
            var hour = $("span.clockpicker-span-hours").text();
            el.val(hour+":"+min);
        }
    });
    $('#endTime').clockpicker({
        autoclose: true,
        init: function() {
            console.log("colorpicker initiated");
        },
        beforeShow: function() {
            $("span.clockpicker-span-hours").text("");
        },
        afterShow: function() {
            console.log("after show");
        },
        beforeHide: function() {
            console.log("before hide");
        },
        afterHide: function() {
            console.log("after hide");
        },
        beforeHourSelect: function() {
            console.log("before hour selected");
        },
        afterHourSelect: function() {
            var el = $("#endTime");
            var min = "00";
            if(el.val().indexOf(":")>0){
                var arr = el.val().split(":");
                min = arr[1];
            }
            var hour = $("span.clockpicker-span-hours").text();
            el.val(hour+":"+min);
        },
        beforeDone: function() {
            console.log("before done");
        },
        afterDone: function() {
            console.log("after done");
        }
    });

    $('#startDate').datepicker({dateFormat: "yy-mm-dd"});
    $('#endDate').datepicker({dateFormat: "yy-mm-dd"});

    $("#frmActivityAdd").validate({
        rules: {
            pStartDate: {
                required: true,
                date: true
            },
            pEndDate: {
                required: true,
                date: true
            }
        },
        messages: {
            pStartDate: "시작날짜를 확인해 주세요 (yyyy-mm-dd)",
            pEndDate: "종료날짜를 확인해 주세요 (yyyy-mm-dd)"
        },
        submitHandler: function (form) {
            onActivity();
        }
    });
    $.validator.addMethod(
            "myDateFormat",
            function (value, element) {
                var re = /^\d{4}-\d{2}-\d{2}$/;
                return (this.optional(element) && value == "") || re.test(value);
            }
    );

    <%if(isModal.equals("Y")) {%>
    modalInit();
    modalOpen();
    <%}%>

});

function modalOpen() {
    $("#register").modal('show');
}

function modalInit() {
    $("#register #activityIdx").val("");
    $("#register #startDate").val(new Date().format("yyyy-MM-dd"));
    $("#register #startTime").val("");
    $("#register #endDate").val(new Date().format("yyyy-MM-dd"));
    $("#register #endTime").val("");
    $("#register #desc").val("");
    $("#register #observerComment").val("");
    $("#register #taskAssign").val("0");
    $("#register input[name=pObserver]:checkbox").attr("checked", false);
    $("#register #observerCheckList").css("display", "none");
    $("#register #observerDesc").css("display", "none");
    calendar.fullCalendar('unselect');
}

function onActivity() {
    if (lock()) {
        alert("처리 중입니다..");
        return false;
    }

//    var startDate = document.getElementById("startDate");
    var d1 = new Date($("#startDate").val()+" "+$("#startTime").val());
    var d2 = new Date($("#endDate").val()+" "+$("#endTime").val());
    if (d1 > d2) {
        alert("시작일시가 종료일시보다 큽니다.");
        unlock();
        return false;
    }

//    var endDate = document.getElementById("endDate");

    var taskAssign = document.getElementById("taskAssign");
    var observerComment = document.getElementById("observerComment");
    var observerCheck = document.getElementById("observerCheck");
    var observerLength = $("input[name=pObserver]:checkbox:checked").length;

//    var desc = document.getElementById("desc");
//    if (desc.value == '') {
//        alert('내용을 입력하세요');
//        unlock();
//        desc.focus();
//        return;
//    }

    if (observerLength > 0 && observerComment.value == '') {
        alert('참조내용을 입력하세요');
        unlock();
        observerDesc.focus();
        return;
    }

    $.ajax({
        type: 'post',
        async: true,
        url: 'calendarAction.jsp',
        data: $("#frmActivityAdd").serialize(),
        beforeSend: function () {
        },
        success: function (data) {
            if (data > 0) {	// -- TODO - 방금 등록한 액티비티 시퀀스를 받아서 저장해야 함
                location.href = "calendar.jsp?tsk_idx=<%=TASK_IDX%>";
                /*
                 calendar.fullCalendar('renderEvent', {
                 idx : data,
                 title: desc.value,
                 start: startDate.value,
                 end: endDate.value,
                 allDay: true
                 },
                 true
                 );

                 $("#register").modal('hide') ;
                 */
            } else {
                alert('등록 실패');
            }
        },
        error: function (data, status, err) {
            alert("Sorry. Activity Register Error");
        },
        complete: function () {
            unlock(); // -- TODO - 예외상황 발생시에도 타는가?

        }
    });
}

function onChange(calEvent, revertFunc) {
    if (!confirm("Are you sure about this change?")) {
        revertFunc();
    }
    else {
        var frm = document.getElementById("frmActivityMove");
        // 최초 액티비티를 Week인 상태에서 생성 후 Allday-> 시간축으로 끌어다 놓으면 idx에 공백이 붙는 현상이 있음. -- 2013.01.18
        frm.pIdx.value = calEvent.idx;

        frm.pStartDate.value = convertDate(calEvent.start);
        frm.pStartTime.value = convertTime(calEvent.start);
        if (!calEvent.end) {
            frm.pEndDate.value = frm.pStartDate.value;
            frm.pEndTime.value = frm.pStartTime.value;
        }
        else {
            frm.pEndDate.value = convertDate(calEvent.end);
            frm.pEndTime.value = convertTime(calEvent.end);
        }
        $.ajax({
            type: 'post',
            async: true,
            url: 'calendarAction2.jsp',
            data: $("#frmActivityMove").serialize(),
            beforeSend: function () {
            },
            success: function (data) {
                if (data > 0) {
                } else {
                    alert('등록 실패');
                    revertFunc();
                }
            },
            error: function (data, status, err) {	// -- 결과 수신에 실패한 경우
                alert("Fail to update:" + err);
                revertFunc();
            }, complete: function () {
            }
        });
    }

}

function convertDate(d) {
    var s =
            padZero(d.getFullYear(), 4) + '-' +
            padZero(d.getMonth() + 1, 2) + '-' +
            padZero(d.getDate(), 2);
    return s;
}

function convertTime(d) {
    var s =
            padZero(d.getHours(), 2) + ':' +
            padZero(d.getMinutes(), 2);
    return s;
}

function padZero(n, digits) {
    var zero = '';
    n = n.toString();

    if (n.length < digits) {
        for (i = 0; i < digits - n.length; i++)
            zero += '0';
    }
    return zero + n;
}

function onChangeTaskAssign(v) {
    if (v.value == "-1") {
        $("#observerCheckList").css("display", "none");
        $("#observerDesc").css("display", "none");
    } else {
        $("#observerCheckList").css("display", "block");
        $("#observerDesc").css("display", "block");
    }
}
<%} else { %>
var calendar;

$(document).ready(function () {
    var wrapHeight = $(document).height();
    var date = new Date();
    var d = date.getDate();
    var m = date.getMonth();
    var y = date.getFullYear();

    calendar = $('#calendar').fullCalendar({
        header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month,agendaWeek,agendaDay'
        },
        editable: false,
        events: [ <%=events%> ]
    });

    var _date = new Date(<%=sLastEndDateTime%>);
    if (_date < new Date()) {
        $('#calendar').fullCalendar('gotoDate', _date);
    }
});
<% } %>
</script>
<style>
    .clockpicker-popover {
        z-index: 30000;
    }

    .clockpicker-popover .popover-title {
        padding-left : 0px;
    }

    .clockpicker-span-hours,.clockpicker-span-minutes {
        float:none;
        margin-left:0px;
        padding-left:0px;
        font-size:24px;
        line-height:30px;
        text-align:center;
        color:#999;
    }

    .clockpicker-popover .text-primary {
        color:#444;
    }
</style>
</head>
<body>
<%@ include file="./taskHierarchyInfo.jsp" %>
<div class="row-fluid">
    <div class='span12'>
        <%@ include file="./menuGlobal.jsp" %>
        <div class="row-fluid">
            <%--<div class='span2 vertNav'><%=getVertNav(req, oUserSession) %></div>--%>
            <div class='span5' id="hierarchy" style="height:100%;"></div>
            <div class='span7'>
                <%@ include file="./menuTool.jsp" %>
                <%--<div style='text-align:right'>CC: <%=_observerImages.toString() %></div>--%>
                <div id="calendar" class='calendarArea'></div>
            </div>
        </div>
    </div>
    <%--<div class='span1'></div>--%>
    <%--<%=getNotification(oUserSession, "span3 noti") %>--%>
</div>
<% if (!readonly) {%>
<div id="register" class="modal hide fade" tabindex="-1" role="dialog"
     aria-labelledby="registerLabel" aria-hidden="true">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
        <h3 id="registerLabel">일정 등록</h3>
    </div>
    <div class="modal-body">
        <form id="frmActivityAdd" class="form-horizontal">
            <input type="hidden" name="tsk_idx" value="<%=TASK_IDX%>"/>
            <input type="hidden" id="activityIdx" name="pActivityIdx" value=""/>

            <div class="control-group">
                <label class="control-label" for="startDate">시작 </label>

                <div class="controls">
                    <input type="text" id="startDate" name="pStartDate" class="myDateFormat" required/>
                    <input type="text" id="startTime" name="pStartTime" value="00:00" data-default="00:00" placeholder="00:00"/>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label" for="endDate">종료</label>

                <div class="controls">
                    <input type="text" id="endDate" name="pEndDate" class="myDateFormat" required/>
                    <input type="text" id="endTime" name="pEndTime" value="00:00" data-default="00:00" placeholder="00:00"/>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label" for="desc">내용</label>

                <div class="controls">
                    <textarea id="desc" name="pDescription" rows=3 placeholder="어떤 활동을 계획 혹은 수행하셨나요?"
                              required></textarea>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label" for="taskAssign">태스크 할당</label>

                <div class="controls">
                    <select id="taskAssign" name="pTaskAssignUserId"
                            onChange="javascript:onChangeTaskAssign(this);"><%=userCombo%>
                    </select>
                </div>
            </div>
            <div class="control-group" id="observerDesc" style="display:none;">
                <label class="control-label" for="desc">메시지</label>

                <div class="controls">
                    <textarea name="pComment" id="observerComment" rows=3 placeholder="참고할 내용을 적어주세요."></textarea>
                </div>
                <%=userCheckbox %>
            </div>
        </form>
    </div>
    <div class="modal-footer">
        <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
        <button class="btn btn-primary" onClick="javascript:$('#frmActivityAdd').submit()">Save changes</button>
    </div>
</div>
<form id="frmActivityMove">
    <input type="hidden" name="pIdx"/>
    <input type="hidden" name="pStartDate"/><input type="hidden" name="pEndDate"/>
    <input type="hidden" name="pStartTime"/><input type="hidden" name="pEndTime"/>
</form>
<%} %>
</body>
</html>
<%@ include file="./common/include/incFooter.jspf" %>
<%!
    class Task {
        int n_idx = -1;
        int n_level = -1;
        String v_desc;
        String v_parent_user;
        String v_task_owner;
        int n_owner_idx = -1;
        String c_status;
        String c_off_yn;
        String c_del_yn;
        String v_hide;

        UserSession sess;

        public Task(DataSet ds, UserSession oUserSession) {
            this.n_idx = ds.getInt(1);
            this.n_level = ds.getInt(2);
            this.v_desc = ds.getString(3);
            this.v_parent_user = ds.getString(4);
            this.v_task_owner = ds.getString(5);
            this.n_owner_idx = ds.getInt(6);
            this.c_status = ds.getString(7);
            this.c_off_yn = ds.getString(8);
            this.c_del_yn = ds.getString(9);
            this.v_hide = ds.getString(10);

            this.sess = oUserSession;
        }

        public boolean isOff() {
            return "Y".equals(c_off_yn);
        }

        public boolean isDel() {
            return "Y".equals(c_off_yn);
        }

        public int getIdx() {
            return n_idx;
        }

        public int getOwnerIdx() {
            return n_owner_idx;
        }

        public boolean isHide() {
            return "Y".equals(v_hide);
        }

        public String get() {
            StringBuffer path = new StringBuffer();
            String[] asParentUser = v_parent_user.split("-");
            if (asParentUser != null && asParentUser.length == 2) {
                int n_parent_idx = Integer.parseInt(asParentUser[0]);
                if (n_owner_idx != n_parent_idx) {
                    path.append(getProfileImage(n_parent_idx, 30));
                    path.append("<i class='icon-hand-right'></i>");
                }
            }
            path.append(getProfileImage(n_owner_idx, 30));

            String outFormat = "%s %s %s";
            return String.format(
                    outFormat
                    , path
                    , v_desc, getStatus());
        }

        private String getStatus() {
            String status = "";
            if ("01".equals(c_status)) {
                status = "<span class='badge badge-warning'>지연</span>";
            } else if ("02".equals(c_status)) {
                status = "<span class='badge badge-warning'>이슈</span>";
            } else if ("03".equals(c_status)) {
                status = "<span class='badge badge-important'>중단</span>";    // -- 혹은 보류?
            } else if ("04".equals(c_status)) {
                status = "<span class='badge badge-important'>실패</span>";
            } else if ("05".equals(c_status)) {
                status = "<span class='badge badge-success'>성공</span>";
            } else {
                status = "<span class='badge badge-success'>정상</span>";
            }

            return status;
        }
    }

    class Activity {
        int currentTaskIdx = -1;
        String n_idx;
        String v_desc;
        String v_start_datetime;
        String v_end_datetime;
        int n_start_gap;
        int n_end_gap;
        int n_task_idx;

        public Activity(DataSet ds, int taskIdx) {
            this.currentTaskIdx = taskIdx;

            this.n_idx = ds.getString(1);
            this.v_desc = ds.getString(2);
            this.v_start_datetime = ds.getString(3);
            this.v_end_datetime = ds.getString(4);

            this.n_start_gap = ds.getInt(5);
            this.n_end_gap = ds.getInt(6);

            this.n_task_idx = ds.getInt(7);
        }

        public long getEndDateTime() {
            return Long.parseLong(v_end_datetime.substring(0, 8));
        }

        public String get() {
            String start_gap = "";
            if (n_start_gap != 0) start_gap = ((n_start_gap > 0) ? "+" : "") + n_start_gap;

            String end_gap = "";
            if (n_end_gap != 0) end_gap = ((n_end_gap > 0) ? "+" : "") + n_end_gap;

            // -- 시간처리
            String start_time = v_start_datetime.substring(8);
            String end_time = v_end_datetime.substring(8);

            //System.out.println("start at "+start_time) ;
            //System.out.println("end at "+end_time) ;

            StringBuffer start = new StringBuffer();
            StringBuffer end = new StringBuffer();

            boolean allday = true;
            start.append(",start:new Date(y,m,d" + start_gap);
            String start_hr = null, start_min = null;
            if (!"000000".equals(start_time)) {
                start_hr = start_time.substring(0, 2);
                start_min = start_time.substring(2, 4);
                start.append("," + start_hr + "," + start_min);
                allday = false;
            }
            start.append(")");    // -- TODO - 시간정보 포함요. y,m,d,H,i


            end.append(",end:new Date(y,m,d" + end_gap);
            String end_hr = null, end_min = null;
            if (!"000000".equals(end_time)) {
                end_hr = end_time.substring(0, 2);
                end_min = end_time.substring(2, 4);
                end.append("," + end_hr + "," + end_min);
                allday = false;
            }
            end.append(")");

            String actDesc = v_desc.replaceAll("\r\n", " ").replaceAll("\n\r", " ").replace("\\", "\\\\").replace("'", "\\'");    // -- 줄바꿈이 있으면 캘린더 출력 못함 // 130806 ' , \ 있을시 달력 안나오는 문제 해결

            String sAllDay = (!allday) ? ",allDay:false" : "";
            String result = "{idx:" + n_idx +
                    ",title:'" + actDesc + "'";    // -- TODO - 특수문자 처리필요. 특히,single quotation
            // -- ",start:new Date(y,m,d"+start_gap+")"+
            // -- ",end:new Date(y,m,d"+end_gap+")"+
            if (n_task_idx == currentTaskIdx) {
                result += ",backgroundColor:'#ffff00'";
                // -- result += ",textColor:'#999999'" ;
            }
            result += start.toString() + end.toString() + sAllDay + "},";

            return result;
        }
    }
%>