<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<html>
<head>
    <meta charset="utf-8">
    <title>确权登记系统</title>
    <!-- jq -->
    <script src="${ctx}/js/jquery-3.1.1.min.js"></script>

    <!-- bootstrap -->
    <link href="${ctx}/css/bootstrap.min.css" rel="stylesheet">
    <script src="${ctx}/js/bootstrap.min.js"></script>

    <!-- 分页插件 -->
    <link href="${ctx}/css/bootstrap-table.min.css" rel="stylesheet">
    <script src="${ctx}/js/bootstrap-table.js"></script>
    <script src="${ctx}/js/bootstrap-table-locale-all.min.js"></script>


    <!--layer -->
    <link href="${ctx}/js/layer/theme/default/layer.css" rel="stylesheet">
    <style type="text/css">
        .panel {
            margin-left: -48px;
            width: 1145px;
        }

        .col-sm-12 {
            margin-left: -60px;
        }

        thead {
            background: #428bca;
            color: white;
        }
    </style>
</head>
<body>
<div class="container" style="margin-top:5px">
    <div class="row">
        <!--!查询区 -->
        <div class="panel panel-default">
            <div class="panel-heading" style="background-color:#428bca;color: white">
                查询条件
            </div>
            <div class="panel-body form-group" style="margin-bottom:0px;">
                <label class="col-sm-2 control-label" style="text-align: right; margin-top:5px">省份：</label>
                <div class="col-sm-2">
                    <input type="text" class="form-control" name="sfmc" id="search_sfmc"/>
                </div>
                <div class="col-sm-1 col-sm-offset-4">
                    <button class="btn btn-primary" class="search" type="button" id="search_btn"
                            style="background-color: #0767C8 ">搜索
                    </button>
                </div>
            </div>
        </div>

        <div id="toolbar" class="btn-group">
            <button id="btn_add" type="button" class="btn btn-success">
                <span class="glyphicon glyphicon-plus" aria-hidden="true"></span>新增
            </button>
            <%--<button id="btn_edit" type="button" class="btn btn-primary" >--%>
            <%--<span class="glyphicon glyphicon-pencil" aria-hidden="true"></span>修改--%>
            <%--</button>--%>
            <shiro:hasPermission name="sfqk_deleteall">
            <button id="btn_delete" type="button" class="btn btn-danger" style="margin-left: 10px">
                <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>批量删除
            </button>
            </shiro:hasPermission>
        </div>
        <!-- 表格 -->
        <div class="col-sm-12">
            <table class="table table-striped table-bordered table-hover" id="table"></table>
        </div>
    </div>
</div>

<script src="${ctx}/js/layer/layer.js"></script>
<script type="text/javascript">

    //获取选中的所有行的id
    function getIds() {
        return $.map($("#table").bootstrapTable('getSelections'), function (row) {
            return row.id;
        })
    }

    //新增
    $("#btn_add").click(function () {
        window.location.href = "${ctx}/sfqk/addSfqk?flag=1";
    })

    //批量删除的方法
    $("#btn_delete").click(function () {
        var ids = getIds();
        if (ids.length < 1) {
            layer.alert('请选择至少一个省份!', {
                skin: 'layui-layer-lan'
                , closeBtn: 0
            })
        } else {
            layer.confirm('确定删除这些省份吗?？', {
                btn: ['是的', '按错了'] //可以无限个按钮
            }, function () {
                //确定按钮的回调函数
                var url = "${ctx}/sfqk/removeSfqk";
                var params = {
                    flag: 2,
                    ids: ids
                }
                $.ajax({
                    url: url,
                    data: params,
                    type: "post",
                    dataType: "json",
                    success:function(data){
                    	if(data=="success"){
                    		setTimeout(function(){
                    			$("#table").bootstrapTable("refresh", {url: '${ctx}/sjson'});
                    		},1000);
                    		layer.closeAll('dialog');
                    	}
                    },
                    error: function () {
                        $("#table").bootstrapTable("refresh", {url: '${ctx}/sjson'});
                    }
                })
            })
        }
    })



    function deleteone(id) {
       layer.confirm('确定删除这个省份吗?', {
            btn: ['是的', '按错了'] //可以无限个按钮
        }, function () {
            //确定按钮的回调函数
            window.location.href = "${ctx}/sfqk/removeSfqk?flag=1&id=" + id;
        })
    };
    
    
    class BstpTable {
        constructor(obj) {
            this.obj = obj;
        }

        inint() {
            //---先销毁表格 ---
            this.obj.bootstrapTable('destroy');
            //---初始化表格,动态从服务器加载数据---
            this.obj.bootstrapTable({
                //【发出请求的基础信息】
                url: '${ctx}/sjson',
                method: 'post',
                contentType: "application/x-www-form-urlencoded",//必须有
                //【查询设置】
                /* queryParamsType的默认值为 'limit' ,在默认情况下 传给服务端的参数为：offset,limit,sort
                                  设置为 ''  在这种情况下传给服务器的参数为：pageSize,pageNumber */
                queryParamsType: '',
                queryParams: function queryParams(params) {
                    //自定义传递的参数
                    var param = {
                        pageNumber: params.pageNumber,
                        pageSize: params.pageSize,
                        sfmc: $("#search_sfmc").val(),
                    };
                    return param;
                },

                //【其它设置】
                locale: 'zh-CN',//中文支持
                pagination:true,//是否开启分页（*）
                striped: true,
                pageNumber: 1,//初始化加载第一页，默认第一页
                pageSize: 5,//每页的记录行数（*）
                pageList: [5, 10, 15],//可供选择的每页的行数（*）
                sidePagination: "server", //分页方式：client客户端分页，server服务端分页（*）
                showRefresh: true,//刷新按钮
                showToggle: true,//卡片视图
                toolbar: '#toolbar',//工具栏

                //【样式设置】
                height: 384,
                //按需求设置不同的样式：5个取值代表5中颜色['active', 'success', 'info', 'warning', 'danger'];
                rowStyle: function (row, index) {
                    var style = "";
                    if (row.username == "千锋教育") {
                        style = 'success';
                    }
                    if (row.username == "传智播客") {
                        style = 'info';
                    }
                    if (row.username == "lucifer") {
                        style = 'danger';
                    }
                    if (row.username == "一加") {
                        style = "active";
                    }
                    if (row.username == "联想") {
                        style = "warning";
                    }
                    return {classes: style}
                },

                //【设置列】
                columns: [
                    {
                        title: '全选',
                        field: 'select',
                        //复选框
                        checkbox: true,
                        width: 25,
                        align: 'center',
                        valign: 'middle'
                    },
                    {field: 'sqhdm', title: '省区划代码'},
                    {field: 'sfmc', title: '省份'},
                    {field: 'sccbdmj', title: '实测承包地面积'},
                    {field: 'qqmj', title: '承包地确权面积'},
                    {field: 'bzs', title: '颁发土地承包经营权证书数'},
                    {field: 'wcqqqk', title: '完成土地确权情况'},
                    {
                        field: 'tool', title: '操作', align: 'center',
                        formatter: function (value, row, index) {
                            var element =
                                "<a  data-id='" + row.id + "' href='${ctx}/sfqk/updateSfqk?flag=1&id=" + row.id + "' class='btn btn-info btn-sm'>编辑</a> &nbsp;" +
                                "<button  data-id='" + row.id + "' onclick='deleteone(" + row.id + ")' class='btn btn-danger btn-sm'>删除</button>";
                            return element;
                        }
                    }
                ]
            })
        }
    }

    var bstpTable = new BstpTable($("table"));
    bstpTable.inint({})

    //查询按钮的逻辑
    $("#search_btn").click(function () {
        $("#table").bootstrapTable("refresh", {url:'${ctx}/sjson'})
    })
</script>
</body>
</html>