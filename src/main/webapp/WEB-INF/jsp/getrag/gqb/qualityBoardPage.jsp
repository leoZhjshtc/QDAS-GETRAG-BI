<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" %>
<%@ include file="../meta.jsp" %>
<html>
<head>
    <script type="text/javascript" src="<%=basePath%>resources/js/echarts.min.js"></script>
    <script type="text/javascript" src="<%=basePath%>resources/js/mytheme.js"></script>
    <script type="text/javascript" src="<%=basePath%>resources/js/charts.js"></script>
    <link rel="stylesheet" type="text/css" href="<%=basePath %>resources/css/qm.css"/>
    <title>质量看板</title>
    <script type="text/javascript">
        var today = new Date();
        var timeInt=today.getTime();
        var ago24=new Date(timeInt-24*60*60*1000);
        var startTime = ago24.format('yyyy-MM-dd hh:mm:ss');
        var endTime=today.format('yyyy-MM-dd hh:mm:ss');
        var pageIndex=0;
        var workshopAuto;
        $(function () {
            <%--$('#qbCenterPlPanel').panel('refresh', '<%=basePath%>gqb/initProductLinePage?startTime=' + startTime + "&endTime=" + endTime)--%>
            $('#qbCenterPlPanel').panel('refresh', '<%=basePath%>gqb/initWorkShopMap');
            $('#qbShowDiv').window({
                width: $(window).width() - 100,
                height: $(window).height() - 100,
                title: '看板',
                cache: false,
                collapsible: false,
                minimizable: false,
                modal: true,
                closed: true,
                href: '<%=basePath%>gqb/initQbShowPage',
                onClose: function () {
                    clearInterval(plInterval);
                }
            });
            $('#gobackBtn').click(function () {
                if (!$('#qbChartPanel').panel('options').closed){
                    $('#qbChartPanel').panel('close');
                    $('#qbPlPanel').panel('open');
                    $('#gobackBtn').linkbutton('disable');
                    $('#currentMachineName').parent().removeClass("greenTitle").removeClass("redTitle");
                    $('#currentMachineName').html("");
                }else if(!$('#mmDetailsPanel').panel('options').closed){
                    $('#mmDetailsPanel').panel('close');
                    $('#qbChartPanel').panel('open');
                }else if(!$('#qaMerkmalPanel').panel('options').closed){
                    $('#qaMerkmalPanel').panel('close');
                    $('#qbChartPanel').panel('open');
                }
            })
            // $('#lastWorkshop').click(function () {
            //     console.log("qian")
            // })
            // $('#nextWorkshop').click(function () {
            //     console.log('hou')
            // })
        })

        function lastWorkshopPage() {
            if(pageIndex==0){
                $('#qbCenterPlPanel').panel('refresh', '<%=basePath%>gqb/initWorkShopMap2');
                pageIndex=1
            }else{
                $('#qbCenterPlPanel').panel('refresh', '<%=basePath%>gqb/initWorkShopMap');
                pageIndex=0
            }
        }
        function workShopSwitchChange(flag) {
            if(flag){
                if(workshopAuto!==undefined){
                    clearInterval(workshopAuto)
                }
                $('#lastWorkshop').linkbutton('disable');
                $('#nextWorkshop').linkbutton('disable');
                workshopAuto=setInterval(lastWorkshopPage,10000)
            }else {
                $('#lastWorkshop').linkbutton('enable');
                $('#nextWorkshop').linkbutton('enable');
                if(workshopAuto!==undefined){
                    clearInterval(workshopAuto)
                }
            }
        }
        function timeRadioClick(checked) {
            /*var now = new Date();
            if (checked == 1) {
                startTime = now.format('yyyy-MM-dd 00:00:00');
                endTime = '';
            } else if (checked == 2) {
                var searchTime = now.getTime() - (86400000);
                var yesday = new Date(searchTime)
                startTime = yesday.format('yyyy-MM-dd 00:00:00');
                endTime = now.format('yyyy-MM-dd 00:00:00');
            } else if (checked == 3) {
                var weekStartDate = new Date(now.getFullYear(), now.getMonth(), now.getDate() - now.getDay());
                startTime = weekStartDate.format('yyyy-MM-dd 00:00:00');
                endTime = '';
            }*/
            $('#qbPlPanel').panel('refresh', '<%=basePath%>gqb/initProductLinePage?startTime=' + startTime + "&endTime=" + endTime);
        }

        function plOpenQbShow() {
            pageIndex = 0;
            $('#qbShowDiv').window('open');
        }
    </script>
</head>
<body>
<div class="easyui-layout" fit="true">
    <div data-options="region:'north',split:false,border:false"
         style="height:30px;overflow: hidden;display: table-cell;vertical-align: middle;background-color: #f3f3f3;font-size:15px;">
        <div style="float: left;">
<%--            <span id="currentWsName"></span>--%>
            <ul class="placeul">
                <li><a id="qaFactoryLi" style="cursor:hand">质量看板</a></li>
            </ul>
        </div>
        <div style="float: left;margin-left: 40%;">
            <ul class="placeul">
                <li id="currentMachineName"></li>
            </ul>
        </div>
        <a id="gobackBtn" class="easyui-linkbutton" data-options="iconCls:'icon-back',disabled:true" style="float: right;width: 80px">返回</a>
    </div>
    <div data-options="region:'center',border:false" style="overflow: hidden;">
        <div class="easyui-layout" fit="true">
            <div data-options="region:'center',border:false">
                <div id="qbPlPanel"  class="easyui-panel" data-options="fit:true,border:false" style="overflow:hidden;">
                    <div class="easyui-layout" fit="true">
                        <div data-options="region:'north',border:true"
                             style="height: 40px;padding: 5px;overflow: hidden;background-color: #EDF4F0">
                            <form style="float: left">
                                <input class="easyui-radiobutton"
                                       data-options="checked:true,onChange:function(checked){if(checked){timeRadioClick(1)}}"
                                       name="plDateChose" value="1" label="近24小时:" labelAlign="right">
                                <%--<input class="easyui-radiobutton"
                                       data-options="onChange:function(checked){if(checked){timeRadioClick(2)}}"
                                       name="plDateChose" value="2" label="昨日:" labelAlign="right">
                                <input class="easyui-radiobutton"
                                       data-options="onChange:function(checked){if(checked){timeRadioClick(3)}}"
                                       name="plDateChose" value="7" label="这周:" labelAlign="right">--%>
                            </form>
                            <div style="float: left;margin-left:35% ">
                                <a id="lastWorkshop" class="easyui-linkbutton" data-options="iconCls:'icon-lastPage'" onclick="lastWorkshopPage()"
                                   style="margin: 0px">向前</a>
                                <input id="workShopSwitch" class="easyui-switchbutton"
                                       data-options="onText:'手动',offText:'自动',onChange:workShopSwitchChange"
                                       style="width: 100px"/>
                                <a id="nextWorkshop" class="easyui-linkbutton" style="margin: 0px" onclick="lastWorkshopPage()"
                                   data-options="iconCls:'icon-nextPage',iconAlign:'right'">向后</a>
                            </div>
                            <a id="plQbShow" class="easyui-linkbutton" data-options="iconCls:'icon-kanbanicon'"
                               onclick="plOpenQbShow();"
                               style="float: right">打开轮播看板</a>
                        </div>
                        <div data-options="region:'center',border:false">
                            <div id="qbCenterPlPanel" class="easyui-panel" data-options="fit:true,border:false" style="overflow:hidden;">
                            </div>
                        </div>
                    </div>
                </div>
                <div id="qbChartPanel" class="easyui-panel" data-options="fit:true,border:false,closed:true"
                     style="overflow:hidden;"></div>
                <div id="mmDetailsPanel" class="easyui-panel" data-options="fit:true,border:false,closed:true"
                     style="overflow:hidden;"></div>
                <div id="qaMerkmalPanel" class="easyui-panel" data-options="fit:true,border:false,closed:true"
                     style="overflow:hidden;"></div>
            </div>
        </div>
    </div>
</div>
<div id="qbShowDiv">
</div>
</body>
</html>