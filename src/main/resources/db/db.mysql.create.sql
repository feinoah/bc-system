-- ##bc平台的mysql建表脚本##

-- 测试用的表
CREATE TABLE BC_EXAMPLE (
    ID int NOT NULL auto_increment,
    NAME varchar(255) NOT NULL COMMENT '名称',
    CODE varchar(255),
    PRIMARY KEY (ID)
) COMMENT='测试用的表';

-- 系统标识相关模块
-- 系统资源
CREATE TABLE BC_IDENTITY_RESOURCE (
    ID int NOT NULL auto_increment,
    UID_ varchar(36) COMMENT '全局标识',
    TYPE_ int(1) NOT NULL COMMENT '类型：1-文件夹,2-内部链接,3-外部链接,4-html',
    STATUS_ int(1) NOT NULL COMMENT '状态：0-已禁用,1-启用中,2-已删除',
    INNER_ int(1) NOT NULL COMMENT '是否为内置对象:0-否,1-是',
    BELONG int COMMENT '所隶属的资源',
    ORDER_ varchar(100) COMMENT '排序号',
    NAME varchar(255) NOT NULL COMMENT '名称',
    URL varchar(255) COMMENT '地址',
    ICONCLASS varchar(255) COMMENT '图标样式',
    OPTION_ text COMMENT '扩展参数',
    PRIMARY KEY (ID)
) COMMENT='系统资源';

-- 角色
CREATE TABLE BC_IDENTITY_ROLE (
    ID int NOT NULL auto_increment,
    CODE varchar(100) NOT NULL COMMENT '编码',
    ORDER_ varchar(100) COMMENT '排序号',
    NAME varchar(255) NOT NULL COMMENT '名称',
    
    UID_ varchar(36) COMMENT '全局标识',
   	TYPE_ int(1) NOT NULL COMMENT '类型',
    STATUS_ int(1) NOT NULL COMMENT '状态：0-已禁用,1-启用中,2-已删除',
    INNER_ int(1) NOT NULL COMMENT '是否为内置对象:0-否,1-是',
    PRIMARY KEY (ID)
) COMMENT='角色';

-- 角色与资源的关联
CREATE TABLE BC_IDENTITY_ROLE_RESOURCE (
    RID int NOT NULL COMMENT '角色ID',
    SID int NOT NULL COMMENT '资源ID',
    PRIMARY KEY (RID,SID)
) COMMENT='角色与资源的关联：角色可以访问哪些资源';
ALTER TABLE BC_IDENTITY_ROLE_RESOURCE ADD CONSTRAINT BCFK_RS_ROLE FOREIGN KEY (RID) 
	REFERENCES BC_IDENTITY_ROLE (ID);
ALTER TABLE BC_IDENTITY_ROLE_RESOURCE ADD CONSTRAINT BCFK_RS_RESOURCE FOREIGN KEY (SID) 
	REFERENCES BC_IDENTITY_RESOURCE (ID);

-- 职务
CREATE TABLE BC_IDENTITY_DUTY (
    ID int NOT NULL auto_increment,
    CODE varchar(100) NOT NULL COMMENT '编码',
    NAME varchar(255) NOT NULL COMMENT '名称',
    PRIMARY KEY (ID)
) COMMENT='职务';

-- 参与者的扩展属性
CREATE TABLE BC_IDENTITY_ACTOR_DETAIL (
    ID int NOT NULL auto_increment,
    CREATE_DATE datetime COMMENT '创建时间',
    WORK_DATE date COMMENT 'user-入职时间',
    SEX int(1) default 0 COMMENT 'user-性别：0-未设置,1-男,2-女',
   	CARD varchar(20) COMMENT 'user-身份证',
    DUTY_ID int COMMENT 'user-职务ID',
   	COMMENT_ varchar(1000) COMMENT '备注',
    PRIMARY KEY (ID)
) COMMENT='参与者的扩展属性';
ALTER TABLE BC_IDENTITY_ACTOR_DETAIL ADD CONSTRAINT BCFK_ACTORDETAIL_DUTY FOREIGN KEY (DUTY_ID) 
	REFERENCES BC_IDENTITY_DUTY (ID);

-- 参与者
CREATE TABLE BC_IDENTITY_ACTOR (
    ID int NOT NULL auto_increment,
    UID_ varchar(36) NOT NULL COMMENT '全局标识',
    TYPE_ int(1) NOT NULL COMMENT '类型：1-用户,2-单位,3-部门,4-岗位',
    STATUS_ int(1) NOT NULL COMMENT '状态：0-已禁用,1-启用中,2-已删除',
    CODE varchar(100) NOT NULL COMMENT '编码',
    NAME varchar(255) NOT NULL COMMENT '名称',
    PY varchar(255) COMMENT '名称的拼音',
    ORDER_ varchar(100) COMMENT '同类参与者之间的排序号',
    EMAIL varchar(255) COMMENT '邮箱',
    PHONE varchar(255) COMMENT '联系电话',
    DETAIL_ID int COMMENT '扩展表的ID',
    INNER_ int(1) NOT NULL COMMENT '是否为内置对象:0-否,1-是',
    PRIMARY KEY (ID)
) COMMENT='参与者(代表一个人或组织，组织也可以是单位、部门、岗位、团队等)';
ALTER TABLE BC_IDENTITY_ACTOR ADD CONSTRAINT BCFK_ACTOR_ACTORDETAIL FOREIGN KEY (DETAIL_ID) 
	REFERENCES BC_IDENTITY_ACTOR_DETAIL (ID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE BC_IDENTITY_ACTOR ADD INDEX BCIDX_ACTOR_TYPE (TYPE_);

-- 参与者之间的关联关系
CREATE TABLE BC_IDENTITY_ACTOR_RELATION (
    TYPE_ int(2) NOT NULL COMMENT '关联类型',
    MASTER_ID int NOT NULL COMMENT '主控方ID',
   	FOLLOWER_ID int NOT NULL COMMENT '从属方ID',
    ORDER_ varchar(100) COMMENT '从属方之间的排序号',
    PRIMARY KEY (MASTER_ID,FOLLOWER_ID,TYPE_)
) COMMENT='参与者之间的关联关系';
ALTER TABLE BC_IDENTITY_ACTOR_RELATION ADD CONSTRAINT BCFK_AR_MASTER FOREIGN KEY (MASTER_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_IDENTITY_ACTOR_RELATION ADD CONSTRAINT BCFK_AR_FOLLOWER FOREIGN KEY (FOLLOWER_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_IDENTITY_ACTOR_RELATION ADD INDEX BCIDX_AR_TM (TYPE_, MASTER_ID),ADD INDEX BCIDX_AR_TF (TYPE_, FOLLOWER_ID);

-- 认证信息
CREATE TABLE BC_IDENTITY_AUTH (
    ID int NOT NULL auto_increment COMMENT '与Actor表的id对应',
    PASSWORD varchar(32) NOT NULL COMMENT '密码',
    PRIMARY KEY (ID)
) COMMENT='认证信息';
ALTER TABLE BC_IDENTITY_AUTH ADD CONSTRAINT BCFK_AUTH_ACTOR FOREIGN KEY (ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);

-- 标识生成器
CREATE TABLE BC_IDENTITY_IDGENERATOR (
  TYPE_ VARCHAR(45) NOT NULL COMMENT '分类',
  VALUE_ INT NOT NULL COMMENT '当前值',
  FORMAT VARCHAR(45) COMMENT '格式模板,如“case-${V}”、“${T}-${V}”,V代表value的值，T代表type_的值' ,
  PRIMARY KEY (TYPE_)
) COMMENT = '标识生成器,用于生成主键或唯一编码用';

-- 参与者与角色的关联
CREATE TABLE BC_IDENTITY_ROLE_ACTOR (
    AID int NOT NULL COMMENT '参与者ID',
    RID int NOT NULL COMMENT '角色ID',
    PRIMARY KEY (AID,RID)
) COMMENT='参与者与角色的关联：参与者拥有哪些角色';
ALTER TABLE BC_IDENTITY_ROLE_ACTOR ADD CONSTRAINT BCFK_RA_ACTOR FOREIGN KEY (AID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_IDENTITY_ROLE_ACTOR ADD CONSTRAINT BCFK_RA_ROLE FOREIGN KEY (RID) 
	REFERENCES BC_IDENTITY_ROLE (ID);
	
-- ##系统桌面相关模块##
-- 桌面快捷方式
CREATE TABLE BC_DESKTOP_SHORTCUT (
    ID int NOT NULL auto_increment,
    UID_ varchar(36) COMMENT '全局标识',
    STATUS_ int(1) NOT NULL COMMENT '状态：0-已禁用,1-启用中,2-已删除',
    ORDER_ varchar(100) NOT NULL COMMENT '排序号',
    STANDALONE int(1) NOT NULL COMMENT '是否在独立的浏览器窗口中打开',
    NAME varchar(255) COMMENT '名称,为空则使用资源的名称',
    URL varchar(255) COMMENT '地址,为空则使用资源的地址',
    ICONCLASS varchar(255) COMMENT '图标样式',
    SID int COMMENT '对应的资源ID',
    AID int COMMENT '所属的参与者(如果为上级参与者,如单位部门,则其下的所有参与者都拥有该快捷方式)',
    INNER_ int(1) NOT NULL COMMENT '是否为内置对象:0-否,1-是',
    PRIMARY KEY (ID)
) COMMENT='桌面快捷方式';
ALTER TABLE BC_DESKTOP_SHORTCUT ADD CONSTRAINT BCFK_SHORTCUT_RESOURCE FOREIGN KEY (SID) 
	REFERENCES BC_IDENTITY_RESOURCE (ID);
ALTER TABLE BC_DESKTOP_SHORTCUT ADD CONSTRAINT BCFK_SHORTCUT_ACTOR FOREIGN KEY (AID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);

-- 个人设置
CREATE TABLE BC_DESKTOP_PERSONAL (
    ID int NOT NULL auto_increment,
    UID_ varchar(36) COMMENT '全局标识',
    STATUS_ int(1) NOT NULL COMMENT '状态：0-已禁用,1-启用中,2-已删除',
    FONT varchar(2) NOT NULL COMMENT '字体大小，如12、14、16',
    THEME varchar(255) NOT NULL COMMENT '主题名称,如base',
    AID int COMMENT '所属的参与者',
    INNER_ int(1) NOT NULL COMMENT '是否为内置对象:0-否,1-是',
    PRIMARY KEY (ID)
) COMMENT='个人设置';
ALTER TABLE BC_DESKTOP_PERSONAL ADD CONSTRAINT BCFK_PERSONAL_ACTOR FOREIGN KEY (AID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_DESKTOP_PERSONAL ADD UNIQUE INDEX PERSONAL_AID_UNIQUE (AID) ;

-- 消息模块
CREATE TABLE BC_MESSAGE (
    ID int NOT NULL auto_increment,
    UID_ varchar(36) COMMENT '全局标识',
    STATUS_ int(1) NOT NULL default 0 COMMENT '状态：0-发送中,1-已发送,2-已删除,3-发送失败',
    TYPE_ int(1) NOT NULL default 0 COMMENT '消息类型',
    SENDER_ID int NOT NULL COMMENT '发送者',
    SEND_DATE datetime NOT NULL COMMENT '发送时间',
    RECEIVER_ID int NOT NULL COMMENT '接收者',
    READ_ int(1) NOT NULL default 0 COMMENT '已阅标记',
    FROM_ID int COMMENT '来源标识',
    FROM_TYPE int COMMENT '来源类型',
    SUBJECT varchar(255) NOT NULL COMMENT '标题',
    CONTENT text COMMENT '内容',
    PRIMARY KEY (ID)
) COMMENT='消息';
ALTER TABLE BC_MESSAGE ADD CONSTRAINT BCFK_MESSAGE_SENDER FOREIGN KEY (SENDER_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_MESSAGE ADD CONSTRAINT BCFK_MESSAGE_REVEIVER FOREIGN KEY (RECEIVER_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_MESSAGE ADD INDEX BCIDX_MESSAGE_FROMID (FROM_TYPE,FROM_ID);
ALTER TABLE BC_MESSAGE ADD INDEX BCIDX_MESSAGE_TYPE (TYPE_);

-- 工作事项
CREATE TABLE BC_WORK (
    ID int NOT NULL auto_increment,
    CLASSIFIER varchar(500) NOT NULL COMMENT '分类词,可多级分类,级间使用/连接,如“发文类/正式发文”',
    SUBJECT varchar(255) NOT NULL COMMENT '标题',
    FROM_ID int COMMENT '来源标识',
    FROM_TYPE int COMMENT '来源类型',
    FROM_INFO varchar(255) COMMENT '来源描述',
    OPEN_URL varchar(255) COMMENT '打开的Url模板',
    CONTENT text COMMENT '内容',
    PRIMARY KEY (ID)
) COMMENT='工作事项';
ALTER TABLE BC_WORK ADD INDEX BCIDX_WORK_FROMID (FROM_TYPE,FROM_ID);

-- 待办事项
CREATE TABLE BC_WORK_TODO (
    ID int NOT NULL auto_increment,
    WORK_ID int NOT NULL COMMENT '工作事项ID',
    SENDER_ID int NOT NULL COMMENT '发送者',
    SEND_DATE datetime NOT NULL COMMENT '发送时间',
    WORKER_ID int NOT NULL COMMENT '发送者',
    INFO varchar(255) COMMENT '附加说明',
    PRIMARY KEY (ID)
) COMMENT='待办事项';
ALTER TABLE BC_WORK_TODO ADD CONSTRAINT BCFK_TODOWORK_WORK FOREIGN KEY (WORK_ID) 
	REFERENCES BC_WORK (ID);
ALTER TABLE BC_WORK_TODO ADD CONSTRAINT BCFK_TODOWORK_SENDER FOREIGN KEY (SENDER_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_WORK_TODO ADD CONSTRAINT BCFK_TODOWORK_WORKER FOREIGN KEY (WORKER_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);

-- 已办事项
CREATE TABLE BC_WORK_DONE (
    ID int NOT NULL auto_increment,
    FINISH_DATE datetime NOT NULL COMMENT '完成时间',
    FINISH_YEAR int(4) NOT NULL COMMENT '完成时间的年度',
    FINISH_MONTH int(2) NOT NULL COMMENT '完成时间的月份(1-12)',
    FINISH_DAY int(2) NOT NULL COMMENT '完成时间的日(1-31)',

    WORK_ID int NOT NULL COMMENT '工作事项ID',
    SENDER_ID int NOT NULL COMMENT '发送者',
    SEND_DATE datetime NOT NULL COMMENT '发送时间',
    WORKER_ID int NOT NULL COMMENT '发送者',
    INFO varchar(255) COMMENT '附加说明',
    PRIMARY KEY (ID)
) COMMENT='已办事项';
ALTER TABLE BC_WORK_DONE ADD CONSTRAINT BCFK_DONEWORK_WORK FOREIGN KEY (WORK_ID) 
	REFERENCES BC_WORK (ID);
ALTER TABLE BC_WORK_DONE ADD CONSTRAINT BCFK_DONEWORK_SENDER FOREIGN KEY (SENDER_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_WORK_DONE ADD CONSTRAINT BCFK_DONEWORK_WORKER FOREIGN KEY (WORKER_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_WORK_DONE ADD INDEX BCIDX_DONEWORK_FINISHDATE (FINISH_YEAR,FINISH_MONTH,FINISH_DAY);

-- 系统日志
CREATE TABLE BC_LOG_SYSTEM (
    ID int NOT NULL auto_increment,
    TYPE_ int(1) NOT NULL COMMENT '类别：0-登录,1-主动注销,2-超时注销',
    
    CREATE_DATE datetime NOT NULL COMMENT '创建时间',
    SUBJECT varchar(500) NOT NULL COMMENT '标题',
    CREATER_ID int NOT NULL COMMENT '创建人ID',
    CREATER_NAME varchar(255) NOT NULL COMMENT '创建人姓名',
    DEPART_ID int COMMENT '用户所在部门ID，如果用户直接隶属于单位，则为null',
    DEPART_NAME varchar(255) COMMENT '用户所在部门名称，如果用户直接隶属于单位，则为null',
    UNIT_ID int NOT NULL COMMENT '用户所在单位ID',
    UNIT_NAME varchar(255) NOT NULL COMMENT '用户所在单位名称',

    C_IP varchar(100) COMMENT '用户机器IP',
    C_NAME varchar(100) COMMENT '用户机器名称',
    C_INFO varchar(1000) COMMENT '用户浏览器信息：User-Agent',
    S_IP varchar(100) COMMENT '服务器IP',
    S_NAME varchar(100) COMMENT '服务器名称',
    S_INFO varchar(1000) COMMENT '服务器信息',

    CONTENT text COMMENT '详细内容',
    
    UID_ varchar(36) COMMENT '未用',
    STATUS_ int(1) default 0 COMMENT '未用',
    PRIMARY KEY (ID)
) COMMENT='系统日志';
ALTER TABLE BC_LOG_SYSTEM ADD CONSTRAINT BCFK_SYSLOG_USER FOREIGN KEY (CREATER_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_LOG_SYSTEM ADD INDEX BCIDX_SYSLOG_ACTOR (UNIT_ID,DEPART_ID,CREATER_ID);
ALTER TABLE BC_LOG_SYSTEM ADD INDEX BCIDX_SYSLOG_CLIENT (C_IP);
ALTER TABLE BC_LOG_SYSTEM ADD INDEX BCIDX_SYSLOG_SERVER (S_IP);

-- 公告模块
CREATE TABLE BC_BULLETIN (
    ID int NOT NULL auto_increment,
    UID_ varchar(36) NOT NULL COMMENT '关联附件的标识号',
    SCOPE int(1) NOT NULL COMMENT '公告发布范围：0-本单位,1-全系统',
    STATUS_ int(1) NOT NULL COMMENT '状态:0-草稿,1-已发布,2-已过期',
   
    FILE_DATE datetime NOT NULL COMMENT '创建时间',
    OVERDUE_DATE datetime COMMENT '过期日期：为空代表永不过期',
   	ISSUE_DATE datetime COMMENT '发布时间',
    FILE_YEAR int(4) COMMENT '发布时间的年度yyyy',
    FILE_MONTH int(2) COMMENT '发布时间的月份(1-12)',
    FILE_DAY int(2) COMMENT '发布时间的日(1-31)',
    ISSUER_ID int COMMENT '发布人ID',
    ISSUER_NAME varchar(100) COMMENT '发布人姓名',
    
    SUBJECT varchar(500) NOT NULL COMMENT '标题',
    
    AUTHOR_ID int NOT NULL COMMENT '创建人ID',
    AUTHOR_NAME varchar(100) NOT NULL COMMENT '创建人姓名',
    DEPART_ID int COMMENT '创建人所在部门ID，如果用户直接隶属于单位，则为null',
    DEPART_NAME varchar(255) COMMENT '创建人所在部门名称，如果用户直接隶属于单位，则为null',
    UNIT_ID int NOT NULL COMMENT '创建人所在单位ID',
    UNIT_NAME varchar(255) NOT NULL COMMENT '创建人所在单位名称',
    MODIFIER_ID int COMMENT '最后修改人ID',
    MODIFIER_NAME varchar(255) COMMENT '最后修改人名称',
    MODIFIED_DATE datetime COMMENT '最后修改时间',

    CONTENT text NOT NULL COMMENT '详细内容',
    PRIMARY KEY (ID)
) COMMENT='公告模块';
ALTER TABLE BC_BULLETIN ADD CONSTRAINT BCFK_BULLETIN_ISSUER FOREIGN KEY (ISSUER_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_BULLETIN ADD INDEX BCIDX_BULLETIN_SEARCH (SCOPE,UNIT_ID,STATUS_);
ALTER TABLE BC_BULLETIN ADD INDEX BCIDX_BULLETIN_ARCHIVE (SCOPE,UNIT_ID,STATUS_,FILE_YEAR,FILE_MONTH,FILE_DAY);

-- 文档附件
CREATE TABLE BC_DOCS_ATTACH (
    ID int NOT NULL auto_increment,
    FILE_DATE datetime NOT NULL COMMENT '创建时间',
    STATUS_ int(1) NOT NULL COMMENT '状态：0-已禁用,1-启用中,2-已删除',
    PTYPE varchar(36) NOT NULL COMMENT '所关联文档的类型',
    PUID varchar(36) NOT NULL COMMENT '所关联文档的UID',
   
    SIZE_ int NOT NULL COMMENT '文件的大小(单位为字节)',
    COUNT_ int NOT NULL default 0 COMMENT '文件的下载次数',
    EXT varchar(10) COMMENT '文件扩展名：如png、doc、mp3等',
    APPPATH int(1) NOT NULL COMMENT '指定path的值是相对于应用部署目录下路径还是相对于全局配置的app.data目录下的路径',
    SUBJECT varchar(500) NOT NULL COMMENT '文件名称(不带路径的部分)',
    PATH varchar(500) NOT NULL COMMENT '物理文件保存的相对路径(相对于全局配置的附件根目录下的子路径，如"2011/bulletin/xxxx.doc")',
    
    AUTHOR_ID int NOT NULL COMMENT '创建人ID',
    AUTHOR_NAME varchar(100) NOT NULL COMMENT '创建人姓名',
    DEPART_ID int COMMENT '创建人所在部门ID，如果用户直接隶属于单位，则为null',
    DEPART_NAME varchar(255) COMMENT '创建人所在部门名称，如果用户直接隶属于单位，则为null',
    UNIT_ID int NOT NULL COMMENT '创建人所在单位ID',
    UNIT_NAME varchar(255) NOT NULL COMMENT '创建人所在单位名称',
    MODIFIER_ID int COMMENT '最后修改人ID',
    MODIFIER_NAME varchar(255) COMMENT '最后修改人名称',
    MODIFIED_DATE datetime COMMENT '最后修改时间',
    PRIMARY KEY (ID)
) COMMENT='文档附件,记录文档与其相关附件之间的关系';
ALTER TABLE BC_DOCS_ATTACH ADD CONSTRAINT BCFK_ATTACH_AUTHOR FOREIGN KEY (AUTHOR_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_DOCS_ATTACH ADD INDEX BCIDX_ATTACH_PUID (PUID);
ALTER TABLE BC_DOCS_ATTACH ADD INDEX BCIDX_ATTACH_PTYPE (PTYPE);

-- 附件处理痕迹
CREATE TABLE BC_DOCS_ATTACH_HISTORY (
    ID int NOT NULL auto_increment,
    FILE_DATE datetime NOT NULL COMMENT '处理时间',
    AID int NOT NULL COMMENT '附件ID',
    TYPE_ int NOT NULL COMMENT '处理类型：0-下载,1-在线查看,2-格式转换',
    SUBJECT varchar(500) NOT NULL COMMENT '简单说明',
    FORMAT varchar(10) COMMENT '下载的文件格式或转换后的文件格式：如pdf、doc、mp3等',
    
    AUTHOR_ID int NOT NULL COMMENT '处理人ID',
    AUTHOR_NAME varchar(100) NOT NULL COMMENT '处理人姓名',
    DEPART_ID int COMMENT '处理人所在部门ID，如果用户直接隶属于单位，则为null',
    DEPART_NAME varchar(255) COMMENT '处理人所在部门名称，如果用户直接隶属于单位，则为null',
    UNIT_ID int NOT NULL COMMENT '处理人所在单位ID',
    UNIT_NAME varchar(255) NOT NULL COMMENT '处理人所在单位名称',
    MODIFIER_ID int COMMENT '最后修改人ID',
    MODIFIER_NAME varchar(255) COMMENT '最后修改人名称',
    MODIFIED_DATE datetime COMMENT '最后修改时间',

    C_IP varchar(100) COMMENT '客户端IP',
    C_INFO varchar(1000) COMMENT '浏览器信息：User-Agent',
    
    MEMO varchar(2000) COMMENT '备注',
    PRIMARY KEY (ID)
) COMMENT='附件处理痕迹';
ALTER TABLE BC_DOCS_ATTACH_HISTORY ADD CONSTRAINT BCFK_ATTACHHISTORY_AUTHOR FOREIGN KEY (AUTHOR_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_DOCS_ATTACH_HISTORY ADD CONSTRAINT BCFK_ATTACHHISTORY_ATTACH FOREIGN KEY (AID) 
	REFERENCES BC_DOCS_ATTACH (ID);

-- 用户反馈
CREATE TABLE BC_FEEDBACK (
    ID int NOT NULL auto_increment,
    UID_ varchar(36) NOT NULL COMMENT '关联附件的标识号',
    STATUS_ int(1) NOT NULL COMMENT '状态:0-草稿,1-已提交,2-已受理',
   
    FILE_DATE datetime NOT NULL COMMENT '创建时间',
    FILE_YEAR int(4) COMMENT '发布时间的年度yyyy',
    FILE_MONTH int(2) COMMENT '发布时间的月份(1-12)',
    FILE_DAY int(2) COMMENT '发布时间的日(1-31)',
    
    SUBJECT varchar(500) NOT NULL COMMENT '标题',
    
    AUTHOR_ID int NOT NULL COMMENT '创建人ID',
    AUTHOR_NAME varchar(100) NOT NULL COMMENT '创建人姓名',
    DEPART_ID int COMMENT '创建人所在部门ID，如果用户直接隶属于单位，则为null',
    DEPART_NAME varchar(255) COMMENT '创建人所在部门名称，如果用户直接隶属于单位，则为null',
    UNIT_ID int NOT NULL COMMENT '创建人所在单位ID',
    UNIT_NAME varchar(255) NOT NULL COMMENT '创建人所在单位名称',
    MODIFIER_ID int COMMENT '最后修改人ID',
    MODIFIER_NAME varchar(255) COMMENT '最后修改人名称',
    MODIFIED_DATE datetime COMMENT '最后修改时间',

    CONTENT text NOT NULL COMMENT '详细内容',
    PRIMARY KEY (ID)
) COMMENT='用户反馈';
ALTER TABLE BC_FEEDBACK ADD CONSTRAINT BCFK_FEEDBACK_AUTHOR FOREIGN KEY (AUTHOR_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_FEEDBACK ADD INDEX BCIDX_FEEDBACK_SEARCH (UNIT_ID,STATUS_);
ALTER TABLE BC_FEEDBACK ADD INDEX BCIDX_FEEDBACK_ARCHIVE (UNIT_ID,STATUS_,FILE_YEAR,FILE_MONTH,FILE_DAY);


-- 选项模块
-- 选项分组
CREATE TABLE BC_OPTION_GROUP (
    ID int NOT NULL auto_increment,
    KEY_ varchar(255) NOT NULL COMMENT '键',
    VALUE_ varchar(255) NOT NULL COMMENT '值',
    ORDER_ varchar(100) COMMENT '排序号',
    ICON varchar(100) COMMENT '图标样式',
    PRIMARY KEY (ID)
) COMMENT='选项分组';
ALTER TABLE BC_OPTION_GROUP ADD INDEX BCIDX_OPTIONGROUP_KEYVALUE (KEY_,VALUE_);

-- 选项条目
CREATE TABLE BC_OPTION_ITEM (
    ID int NOT NULL auto_increment,
    PID int NOT NULL COMMENT '所属分组的ID',
    KEY_ varchar(255) NOT NULL COMMENT '键',
    VALUE_ varchar(255) NOT NULL COMMENT '值',
    ORDER_ varchar(100) COMMENT '排序号',
    ICON varchar(100) COMMENT '图标样式',
    STATUS_ int(1) NOT NULL COMMENT '状态：0-已禁用,1-启用中,2-已删除',
    PRIMARY KEY (ID)
) COMMENT='选项条目';
ALTER TABLE BC_OPTION_ITEM ADD CONSTRAINT BCFK_OPTIONITEM_OPTIONGROUP FOREIGN KEY (PID) 
	REFERENCES BC_OPTION_GROUP (ID);
ALTER TABLE BC_OPTION_ITEM ADD INDEX BCIDX_OPTIONITEM_KEYVALUE (KEY_,VALUE_);

-- bc营运管理子系统的建表脚本,所有表名须附带前缀"BS_"
-- 运行此脚本之前需先运行平台的建表脚本framework.db.mysql.create.sql

-- 车辆 
create table BS_CAR (
    ID int NOT NULL auto_increment,
    UNIT_ID int COMMENT '所属单位ID',
    NAME varchar(500) NOT NULL COMMENT '名称',
    DESC_ text COMMENT '备注',
    primary key (ID)
) COMMENT='车辆';
-- 车队信息
create table BS_MOTORCADE (
    ID int NOT NULL auto_increment,
    UID_ varchar(36)  COMMENT '关联附件的标识号',
   
    FILE_DATE datetime NOT NULL COMMENT '创建时间',

    AUTHOR_ID int NOT NULL COMMENT '创建人ID',
    AUTHOR_NAME varchar(100) NOT NULL COMMENT '创建人姓名',
    DEPART_ID int COMMENT '创建人所在部门ID，如果用户直接隶属于单位，则为null',
    DEPART_NAME varchar(255) COMMENT '创建人所在部门名称，如果用户直接隶属于单位，则为null',
    UNIT_ID int NOT NULL COMMENT '创建人所在单位ID',
    UNIT_NAME varchar(255) NOT NULL COMMENT '创建人所在单位名称',

    CODE varchar(100) NOT NULL COMMENT '编码',
    NAME varchar(255) NOT NULL COMMENT '简称',
    FULLNAME varchar(255) NOT NULL COMMENT '全称',
    STATUS_ int(1) NOT NULL COMMENT '状态：0-已禁用,1-启用中,2-已删除',
    PAYMENT_DATE datetime COMMENT '缴费日期',
    COMPANY varchar(255) NOT NULL COMMENT '公司',
    COLOUR varchar(255) NOT NULL COMMENT '颜色',
    ADDRESS varchar(255) NOT NULL COMMENT '地址',
    PRINCIPAL varchar(255) NOT NULL COMMENT '负责人',
    PHONE varchar(255) NOT NULL COMMENT '电话',
    FAX varchar(255) NOT NULL COMMENT '传真',
    DESC_ text COMMENT '备注',
   
    MODIFIER_ID int COMMENT '最后修改人ID',
    MODIFIER_NAME varchar(255) COMMENT '最后修改人名称',
    MODIFIED_DATE datetime COMMENT '最后修改时间',
    
    primary key (ID)
) COMMENT='车队信息';
ALTER TABLE BS_MOTORCADE ADD CONSTRAINT BS_MOTORCADE_AUTHOR FOREIGN KEY (AUTHOR_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
	
	
-- 查看历史车辆数
create table BS_HISTORY_CAR_QUANTITY(
    ID int NOT NULL auto_increment,
    
    UID_ varchar(36)  COMMENT '关联附件的标识号',
   
    FILE_DATE datetime NOT NULL COMMENT '创建时间',

    AUTHOR_ID int NOT NULL COMMENT '创建人ID',
    AUTHOR_NAME varchar(100) NOT NULL COMMENT '创建人姓名',
    DEPART_ID int COMMENT '创建人所在部门ID，如果用户直接隶属于单位，则为null',
    DEPART_NAME varchar(255) COMMENT '创建人所在部门名称，如果用户直接隶属于单位，则为null',
    UNIT_ID int NOT NULL COMMENT '创建人所在单位ID',
    UNIT_NAME varchar(255) NOT NULL COMMENT '创建人所在单位名称',

    MOTORCADE_ID int NOT NULL COMMENT '车队ID',
    MOTORCADE_NAME varchar(100) NOT NULL COMMENT '车队名',

    YEAR varchar(100) NOT NULL COMMENT '年份',
    MONTH varchar(255) NOT NULL COMMENT '月份',
    CARQUANTITY int(4) NOT NULL COMMENT '车辆数',
    
    MODIFIER_ID int COMMENT '最后修改人ID',
    MODIFIER_NAME varchar(255) COMMENT '最后修改人名称',
    MODIFIED_DATE datetime COMMENT '最后修改时间',
    STATUS_ int(1)  COMMENT '状态：0-已禁用,1-启用中,2-已删除',
    
    primary key (ID)
)COMMENT='查看历史车辆数';
ALTER TABLE BS_HISTORY_CAR_QUANTITY ADD CONSTRAINT BS_HISTORY_CAR_QUANTITY_MOTORCADE FOREIGN KEY (MOTORCADE_ID) 
	REFERENCES BS_MOTORCADE (ID);
ALTER TABLE BS_HISTORY_CAR_QUANTITY ADD CONSTRAINT BS_HISTORY_CAR_QUANTITY_AUTHOR FOREIGN KEY (AUTHOR_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);


-- 证件
create table BS_CERT (
    ID int NOT NULL auto_increment,
    STATUS_ int(1) NOT NULL COMMENT '状态：0-已禁用,1-启用中,2-已删除',
    UID_ varchar(36) NOT NULL,
    CERT_CODE varchar(255) NOT NULL COMMENT '证件号',
    CERT_NAME varchar(255) NOT NULL COMMENT '证件简称',
    CERT_FULL_NAME varchar(255) COMMENT '证件全称',
    LICENCER varchar(255) COMMENT '发证机关',
    ISSUE_DATE datetime COMMENT '发证日期',
    START_DATE datetime COMMENT '生效日期',
    END_DATE datetime COMMENT '到期日期',
    EXT_STR1 varchar(255),
    EXT_STR2 varchar(255),
    EXT_STR3 varchar(255),
    EXT_NUM1 int(19),
    EXT_NUM2 int(19),
    EXT_NUM3 int(19),
    
    FILE_DATE datetime NOT NULL COMMENT '创建时间',
    AUTHOR_ID int NOT NULL COMMENT '创建人ID',
    AUTHOR_NAME varchar(100) NOT NULL COMMENT '创建人姓名',
    DEPART_ID int COMMENT '创建人所在部门ID，如果用户直接隶属于单位，则为null',
    DEPART_NAME varchar(255) COMMENT '创建人所在部门名称，如果用户直接隶属于单位，则为null',
    UNIT_ID int NOT NULL COMMENT '创建人所在单位ID',
    UNIT_NAME varchar(255) NOT NULL COMMENT '创建人所在单位名称',
    MODIFIER_ID int COMMENT '最后修改人ID',
    MODIFIER_NAME varchar(255) COMMENT '最后修改人名称',
    MODIFIED_DATE datetime COMMENT '最后修改时间',
    primary key (ID)
) COMMENT='证件';
ALTER TABLE BS_CERT ADD INDEX BSIDX_CERT_CODE (CERT_CODE);
ALTER TABLE BS_CERT ADD INDEX BSIDX_CERT_NAME (CERT_NAME);

-- 证件:居民身份证
create table BS_CERT_IDENTITY (
    ID int NOT NULL,
    NAME varchar(255) COMMENT '姓名',
    SEX int(1) COMMENT '性别(0-未设置,1-男,2-女)',
    BIRTHDATE datetime COMMENT '出生日期',
    NATION varchar(255) COMMENT '民族',
    ADDRESS varchar(500) COMMENT '住址',
    primary key (ID)
) COMMENT='证件:居民身份证';
ALTER TABLE BS_CERT_IDENTITY ADD CONSTRAINT BSFK_CERT4IDENTITY_CERT FOREIGN KEY (ID) 
	REFERENCES BS_CERT (ID);

-- 证件:机动车驾驶证
create table BS_CERT_DRIVING (
    ID int NOT NULL,
    NAME varchar(255) COMMENT '姓名',
    SEX int(1) COMMENT '性别(0-未设置,1-男,2-女)',
    BIRTHDATE datetime COMMENT '出生日期',
    NATION varchar(255) COMMENT '国籍',
    ADDRESS varchar(500) COMMENT '地址',
    MODEL varchar(255) COMMENT '准驾车型',
    RECEIVEDATE datetime COMMENT '初次领证日期',
    VALIDFOR varchar(255) COMMENT '有效期限',
    ARCHIVENO varchar(255) COMMENT '档案编号',
    RECORD varchar(255) COMMENT '记录',
    primary key (ID)
) COMMENT='证件:机动车驾驶证';
ALTER TABLE BS_CERT_DRIVING ADD CONSTRAINT BSFK_CERT4DRIVING_CERT FOREIGN KEY (ID) 
	REFERENCES BS_CERT (ID);

-- 证件:从业资格证
create table BS_CERT_CYZG (
    ID int NOT NULL,
   NAME                 varchar(255) comment '姓名',
   SEX                  int(1) comment '性别(0-未设置,1-男,2-女)',
   BIRTHDATE            datetime comment '出生日期',
   NATION               varchar(255) comment '民族',
   ADDRESS              varchar(500) comment '住址',
   SCOPE_               varchar(255) comment '从业资格',
   IDENTITY_NO          varchar(255) comment '身份证件号',
   SERVICE_UNIT         varchar(500) comment '服务单位',
   primary key (ID)
) COMMENT '证件:从业资格证';
ALTER TABLE BS_CERT_CYZG ADD CONSTRAINT BSFK_CERT4CYZG_CERT FOREIGN KEY (ID) 
	REFERENCES BS_CERT (ID);

-- 证件:服务资格证
create table BS_CERT_FWZG (
    ID int NOT NULL,
   NAME                 varchar(255) comment '姓名',
   SEX                  int(1) comment '性别(0-未设置,1-男,2-女)',
   BIRTHDATE            datetime comment '出生日期',
   NATION               varchar(255) comment '民族',
   ADDRESS              varchar(500) comment '住址',
   LEVEL_               varchar(255) comment '等级',
   SERVICE_UNIT         varchar(500) comment '服务单位',
   primary key (ID)
)COMMENT '证件:服务资格证';
ALTER TABLE BS_CERT_FWZG ADD CONSTRAINT BSFK_CERT4FWZG_CERT FOREIGN KEY (ID) 
	REFERENCES BS_CERT (ID);

-- 证件:驾驶培训证
create table BS_CERT_JSPX (
    ID int NOT NULL,
   NAME                 varchar(255) comment '姓名',
   SEX                  int(1) comment '性别(0-未设置,1-男,2-女)',
   BIRTHDATE            datetime comment '出生日期',
   NATION               varchar(255) comment '民族',
   ADDRESS              varchar(500) comment '住址',
   DOMAIN               varchar(255) comment '培训专业',
   TRAIN_DATE           datetime comment '培训时间',
   TRAIN_HOUR           int(3) comment '培训学时',
   GRADE1               int(3) comment '理论知识考核成绩',
   GRADE2               varchar(10) comment '操作技能考核成绩',
   GRADE3               varchar(10) comment '评定成绩',
   IDENTITY_NO          varchar(255) comment '身份证件号',
   primary key (ID)
)COMMENT '证件:驾驶培训证';
ALTER TABLE BS_CERT_JSPX ADD CONSTRAINT BSFK_CERT4JSPX_CERT FOREIGN KEY (ID) 
	REFERENCES BS_CERT (ID);
    
-- 证件：机动车行驶证
CREATE TABLE BS_CERT_VEHICELICENSE(
   ID                   int NOT NULL,
   FACTORY              VARCHAR(255) COMMENT '品牌型号，如“桑塔纳SVW7182QQD”',
   PLATE                VARCHAR(255) COMMENT '车牌及号码，如“粤AC4X74”',
   OWNER                VARCHAR(255) COMMENT '业户名称',
   ADDRESS              VARCHAR(255) COMMENT '地址',
   USE_CHARACTER        VARCHAR(255) COMMENT '使用性质',
   VEHICE_TYPE          VARCHAR(255) COMMENT '车辆类型',
   VIN                  VARCHAR(255) COMMENT '车辆识别代号',
   ENGINE_NO            VARCHAR(255) COMMENT '发动机号码',
   REGISTER_DATE        DATETIME COMMENT '注册日期',
   ARCHIVE_NO           VARCHAR(255) COMMENT '档案编号',
   DIM_LEN              int COMMENT '外廓尺寸：长，单位MM',
   DIM_WIDTH            int COMMENT '外廓尺寸：宽，单位MM',
   DIM_HEIGHT           int COMMENT '外廓尺寸：高，单位MM',
   TOTAL_WEIGHT         int COMMENT '总质量，单位KG',
   CURB_WEIGHT          int COMMENT '整备质量，单位KG',
   ACCESS_WEIGHT        int COMMENT '核定载质量，单位KG',
   ACCESS_COUNT         int COMMENT '核定载人数',
   SCRAP_DATE           DATETIME COMMENT '强制报废日期',
   DESC_                VARCHAR(500) COMMENT '备注',
   RECORD_              VARCHAR(500) COMMENT '检验记录',
   PRIMARY KEY (ID)
) COMMENT '证件：机动车行驶证';
ALTER TABLE BS_CERT_VEHICELICENSE ADD CONSTRAINT BSFK_CERT4VEHICELICENSE_CERT FOREIGN KEY (ID)
      REFERENCES BS_CERT (ID);
	  
-- 证件：机动车行驶证
CREATE TABLE BS_CERT_ROADTRANSPORT(
   ID                   int NOT NULL,
   FACTORY              VARCHAR(255) COMMENT '品牌型号，如“桑塔纳SVW7182QQD”',
   PLATE                VARCHAR(255) COMMENT '车牌及号码，如“粤AC4X74”',
   OWNER                VARCHAR(255) COMMENT '业户名称',
   ADDRESS              VARCHAR(255) COMMENT '地址',
   BS_CERT_NO           VARCHAR(255) COMMENT '经营许可证号',
   SEAT                 VARCHAR(255) COMMENT '吨（座）位',
   DIM_LEN              int COMMENT '外廓尺寸：长，单位MM',
   DIM_WIDTH            int COMMENT '外廓尺寸：宽，单位MM',
   DIM_HEIGHT           int COMMENT '外廓尺寸：高，单位MM',
   SCOPE_               VARCHAR(255) COMMENT '经营范围',
   LEVEL_               VARCHAR(255) COMMENT '技术等级',
   PRIMARY KEY (ID)
) COMMENT '证件：道路运输证';
ALTER TABLE BS_CERT_ROADTRANSPORT ADD CONSTRAINT BSFK_CERT4ROADTRANSPORT_CERT FOREIGN KEY (ID)
      REFERENCES BS_CERT (ID);


-- 司机责任人
create table BS_CARMAN (
    ID int NOT NULL auto_increment,
    UID_ varchar(36) NOT NULL COMMENT 'UID',
    STATUS_ int(1) NOT NULL COMMENT '状态：0-已禁用,1-启用中,2-已删除',
    TYPE_ int(1) default 0 NOT NULL COMMENT '类别:0-司机,1-责任人,2-司机和责任人',
    NAME varchar(255) NOT NULL COMMENT '姓名',
    ORDER_ varchar(100) COMMENT '排序号',
    SEX int(1) default 0 NOT NULL COMMENT 'user-性别：0-未设置,1-男,2-女',
    WORK_DATE datetime COMMENT '入职日期',
    ORIGIN               varchar(255) comment '籍贯',
    REGION_              varchar(255) comment '区域',
    HOUSE_TYPE           varchar(255) comment '户口类型',
    FORMER_UNIT          varchar(255) comment '入职原单位',
    ADDRESS              varchar(500) comment '身份证住址',
    ADDRESS1             varchar(500) comment '暂住地址',
    PHONE                varchar(500) comment '电话',
    PHONE1               varchar(500) comment '电话1',
    FILE_DATE datetime NOT NULL COMMENT '创建时间',
    AUTHOR_ID int NOT NULL COMMENT '创建人ID',
    AUTHOR_NAME varchar(100) NOT NULL COMMENT '创建人姓名',
    DEPART_ID int COMMENT '创建人所在部门ID，如果用户直接隶属于单位，则为null',
    DEPART_NAME varchar(255) COMMENT '创建人所在部门名称，如果用户直接隶属于单位，则为null',
    UNIT_ID int NOT NULL COMMENT '创建人所在单位ID',
    UNIT_NAME varchar(255) NOT NULL COMMENT '创建人所在单位名称',
    MODIFIER_ID int COMMENT '最后修改人ID',
    MODIFIER_NAME varchar(255) COMMENT '最后修改人名称',
    MODIFIED_DATE datetime COMMENT '最后修改时间',
    primary key (ID)
) COMMENT='司机责任人';
ALTER TABLE BS_CARMAN ADD CONSTRAINT BSFK_CARMAN_AUTHOR FOREIGN KEY (AUTHOR_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);

-- 司机责任人与证件的关联
CREATE TABLE BS_CARMAN_CERT (
    MAN_ID int NOT NULL COMMENT '司机责任人ID',
    CERT_ID int NOT NULL COMMENT '证件ID',
    PRIMARY KEY (MAN_ID,CERT_ID)
) COMMENT='司机责任人与证件的关联';
ALTER TABLE BS_CARMAN_CERT ADD CONSTRAINT BSFK_CARMANCERT_MAN FOREIGN KEY (MAN_ID) 
	REFERENCES BS_CARMAN (ID);
ALTER TABLE BS_CARMAN_CERT ADD CONSTRAINT BSFK_CARMANCERT_CERT FOREIGN KEY (CERT_ID) 
	REFERENCES BS_CERT (ID);

