/**
 * 
 */
package cn.bc.index;

import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.interceptor.SessionAware;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;

import cn.bc.Context;
import cn.bc.core.exception.CoreException;
import cn.bc.core.util.DateUtils;
import cn.bc.desktop.domain.Personal;
import cn.bc.desktop.domain.Shortcut;
import cn.bc.desktop.service.LoginService;
import cn.bc.desktop.service.PersonalService;
import cn.bc.desktop.service.ShortcutService;
import cn.bc.identity.domain.Actor;
import cn.bc.identity.domain.Resource;
import cn.bc.identity.domain.Role;
import cn.bc.identity.web.SystemContext;
import cn.bc.web.ui.html.menu.Menu;
import cn.bc.web.ui.html.menu.MenuItem;

import com.opensymphony.xwork2.ActionSupport;

/**
 * @author dragon
 * 
 */
@Controller
@Scope(BeanDefinition.SCOPE_PROTOTYPE)
public class IndexAction extends ActionSupport implements SessionAware {
	private static final long serialVersionUID = 1L;
	private static Log logger = LogFactory.getLog(IndexAction.class);
	private ShortcutService shortcutService;
	private List<Shortcut> shortcuts;
	private Personal personalConfig;// 个人配置
	private Map<String, Object> session;
	public String msg;
	public String startMenu;// 开始菜单
	private LoginService loginService;

	public String contextPath;

	@Autowired
	public void setLoginService(LoginService loginService) {
		this.loginService = loginService;
	}

	public IndexAction() {
		contextPath = ServletActionContext.getRequest().getContextPath();
	}

	public Context getContext() {
		return (Context) this.session.get(Context.KEY);
	}

	public void setSession(Map<String, Object> session) {
		this.session = session;
	}

	@Autowired
	public void setShortcutService(ShortcutService shortcutService) {
		this.shortcutService = shortcutService;
	}

	public Personal getPersonalConfig() {
		return personalConfig;
	}

	public void setPersonalConfig(Personal personalConfig) {
		this.personalConfig = personalConfig;
	}

	public List<Shortcut> getShortcuts() {
		return shortcuts;
	}

	public void setShortcuts(List<Shortcut> shortcuts) {
		this.shortcuts = shortcuts;
	}

	public String index1() throws Exception {
		return this.execute();
	}

	public String execute() throws Exception {
		Date startTime = new Date();
		// 检测用户是否登录,未登录则跳转到登录页面
		SystemContext context = (SystemContext) this.session.get(Context.KEY);
		if (context == null || context.getUser() == null) {
			return "redirect";
		}
		Actor user = context.getUser();

		// 个人配置
		this.personalConfig = this.loginService.loadPersonal(user.getId());
		if (this.personalConfig == null)
			throw new CoreException("缺少配置信息！");
		logger.info("index.personal:" + DateUtils.getWasteTime(startTime));

		//当前用户拥有的角色id
		Long[] roleIds = context.getAttr(SystemContext.KEY_ROLEIDS);
		//当前用户及其祖先的id
		Long[] actorIds = context.getAttr(SystemContext.KEY_ANCESTORS);
		
		//查询可访问的资源
		List<Map<String, String>> resources = this.loginService
				.findResources(roleIds);
		List<Long> resourceIds = new ArrayList<Long>();
		for (Map<String, String> resource : resources) {
			resourceIds.add(new Long(resource.get("id")));
		}
		
		//查询可访问的快捷方式
		List<Map<String, String>> shortcuts = this.loginService.findShortcuts(
				actorIds, resourceIds.toArray(new Long[0]));

		logger.info("index.shortcuts:" + DateUtils.getWasteTime(startTime));
		if (logger.isDebugEnabled()) {
			logger.debug("shortcuts=" + shortcuts.size());
			int i = 0;
			for (Map<String, String> resource : resources) {
				logger.debug(++i + ") " + resource.get("pname") + "/" + resource.get("name"));
			}
		}

		// 找到顶层模块
//		Map<Resource, Set<Resource>> parentChildren = new LinkedHashMap<Resource, Set<Resource>>();
//		Set<Resource> topResources = this.findTopResources(resources,
//				parentChildren);
//		if (logger.isDebugEnabled()) {
//			int i = 0;
//			for (Resource m : topResources) {
//				logger.debug(++i + ") " + m);
//			}
//			i = 0;
//			for (Entry<Resource, Set<Resource>> m : parentChildren.entrySet()) {
//				logger.debug(++i + ") " + m.getKey() + " "
//						+ m.getValue().size());
//			}
//		}
//
//		// 循环顶层模块生成菜单
//		Menu menu = this.buildMenu4Resources(topResources, parentChildren);
//		menu.addClazz("startMenu").addClazz("bc-menubar").setId("sysmenu");
//
//		this.startMenu = menu.toString();
		if (logger.isDebugEnabled())
			logger.debug("startMenu=" + startMenu);
		if (logger.isInfoEnabled())
			logger.info("index耗时：" + DateUtils.getWasteTime(startTime));
		return SUCCESS;
	}

	private Set<Resource> findTopResources(Set<Resource> resources,
			Map<Resource, Set<Resource>> parentChildren) {
		Set<Resource> topResources = new LinkedHashSet<Resource>();
		for (Resource m : resources) {
			this.dealParentChildren(m, parentChildren, topResources);
		}
		return topResources;
	}

	private void dealParentChildren(Resource m,
			Map<Resource, Set<Resource>> parentChildren,
			Set<Resource> topResources) {
		Resource parent = m.getBelong();
		if (parent != null) {// 有隶属的父模块
			Set<Resource> childResources = parentChildren.get(parent);
			if (childResources == null) {
				childResources = new LinkedHashSet<Resource>();
				parentChildren.put(parent, childResources);
			}
			childResources.add(m);

			this.dealParentChildren(parent, parentChildren, topResources);
		} else {// 顶层模块
			topResources.add(m);
		}
	}

	private Menu buildMenu4Resources(Set<Resource> resources,
			Map<Resource, Set<Resource>> parentChildren) {
		Menu menu = new Menu();
		MenuItem menuItem;
		for (Resource m : resources) {
			menuItem = buildMenuItem4Resource(m, parentChildren);
			menu.addMenuItem(menuItem);
		}
		return menu;
	}

	private MenuItem buildMenuItem4Resource(Resource m,
			Map<Resource, Set<Resource>> parentChildren) {
		MenuItem menuItem;
		menuItem = new MenuItem();
		menuItem.setUrl(buildMenuItemUrl(m))
				.setLabel(m.getName())
				.setType(String.valueOf(m.getType()))
				.setAction("menuItem")
				.setAttr("data-mid", m.getId().toString())
				.setAttr("data-type", String.valueOf(m.getType()))
				.setAttr("data-standalone",
						String.valueOf(m.getType() == Resource.TYPE_OUTER_LINK))
				.setAttr("data-order", m.getOrderNo())
				.setAttr("data-iconClass", m.getIconClass())
				.setAttr("data-name", m.getName());
		if (m.getOption() != null)
			menuItem.setAttr("data-option",
					m.getOption() == null ? "" : m.getOption());
		if (m.getUrl() != null)
			menuItem.setAttr("data-url",
					m.getUrl().startsWith("/") ? getContextPath() + m.getUrl()
							: m.getUrl());
		if (m.getType() == Resource.TYPE_FOLDER) {// 文件夹
			Set<Resource> childResources = parentChildren.get(m);// 模块下的子模块
			if (childResources != null && !childResources.isEmpty()) {
				menuItem.setChildMenu(buildMenu4Resources(childResources,
						parentChildren));
			}
		}
		return menuItem;
	}

	private String buildMenuItemUrl(Resource m) {
		String url = m.getUrl();
		if (url != null && url.length() > 0) {
			if (m.getType() == Resource.TYPE_OUTER_LINK) {// 不处理外部链接
				return url.startsWith("http") ? url : contextPath + url;
			} else {
				return contextPath + url;// 内部的url需要附加部署路路径
			}
		} else {
			return null;
		}
	}

	/** 获取访问该ation的上下文路径 */
	protected String getContextPath() {
		return ServletActionContext.getRequest().getContextPath();
	}
}
