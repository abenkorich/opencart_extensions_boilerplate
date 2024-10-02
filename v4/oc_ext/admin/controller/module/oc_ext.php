<?php
namespace Opencart\Admin\Controller\Extension\oc_ext\Module;
class oc_ext extends \Opencart\System\Engine\Controller {
    
    	 protected string $method_separator; 
	 protected $conf  = array();  
	
	 // OK
	 public function __construct(\Opencart\System\Engine\Registry $registry) {
		 parent::__construct($registry);
		 
		 $this->method_separator = version_compare(VERSION,'4.0.2.0','>=') ? '.' : '|';
	
		 //$this->config->load('benadev/bd_extensions');
		 //$this->conf = $this->config->get('config');
		 //$API_ENDPOINT = $this->conf['$API_ENDPOINT'];
		 
		 $this->load->language('extension/oc_ext/module/oc_ext');
		 $this->document->setTitle($this->language->get('text_title'));
		 
		 $this->load->model('extension/benadev/module/bd_modules');
		 $this->load->model('extension/oc_ext/module/oc_ext');
	 }
	 
	 public function checkCoreModule(){
		 
		 $this->load->model('setting/extension');
		 
		 $installed_modules = $this->model_setting_extension->getInstalls();
		 $bd_modules = $this->model_setting_extension->getExtensionByCode('module', 'bd_modules');
		 $bd_modules_event = $this->model_setting_event->getEventByCode('bd_modules');
	
		 // check if the bd mcore module is installed and the vent is created
		 if ($bd_modules && $bd_modules_event) {
			 return true;
		 } else {
			 return false;
		 }
	 }
	 
	 // Ext Installation
	 public function installDB() {
		 $this->model_extension_oc_ext->installDBTables();
	 }
	 
	 // Ext Installation
	 public function install() {
		 
		 $this->load->model('setting/event');
		 $this->model_extension_oc_ext->installDBTables();
		 
		 if ( $this->checkCoreModule() ) {
			 if (version_compare(VERSION,'4.0.1.0','>=')) {
				 $data = [
					 'code'        => 'oc_ext',
					 'description' => 'A Drag and Drop responsive layout designer for opencart',
					 'trigger'     => 'admin/view/common/column_left/before',
					 'action'      => 'extension/oc_ext/module/oc_ext' . $this->method_separator . 'eventHandler',
					 'status'      => true,
					 'sort_order'  => 0
				 ];
				 $this->model_setting_event->addEvent($data);
			 } else {
				 $this->model_setting_event->addEvent('oc_ext','','admin/view/common/column_left/before','extension/oc_ext/module/oc_ext'.$this->method_separator.'eventHandler');
			 }
			 $this->generateMenu();
			 $this->addAccessRights();
		 } else {
			 return "Benadev core module need to be installed first";
		 }
	 }
	
	 // Ext DEsinstallation
	 public function uninstall() {
		 $this->load->model('setting/event');
		 $this->model_setting_event->deleteEventByCode('oc_ext');
		 $this->model_extension_benadev_module_bd_modules->deleteModule('oc_ext');
		 $this->removeAccessRights();
	 }
	
	 // Add to the left menu event 
	 public function eventHandler($route, &$data){
		 $this->generateMenu();
	 }
	 
	 public function generateMenu(){
	
		 $this->load->model('setting/setting');
		 $this->load->language('extension/oc_ext/module/oc_ext');
		 
		 $menu = array();
			 
		 // setting sub menu
		 if ($this->user->hasPermission('access', 'extension/oc_ext/module/oc_ext')) {
			 $menu = [
				 'name'	   => $this->language->get('text_title'),
				 'href'     => $this->url->link('extension/oc_ext/module/oc_ext'.$this->method_separator.'getList', 'user_token='),
				 'children' => []
			 ];
		 }
	
		 $data['name'] = 'oc_ext';
		 $data['parent'] = '';
		 $data['menu_items'] = $menu;
		 $data['status'] = '1';
		 
		 $this->model_extension_benadev_module_bd_modules->addModule($data);
	
	 }
	 
	 protected function addAccessRights() {
		 $this->load->model('user/user_group');
		 $this->model_user_user_group->addPermission($this->user->getGroupId(), 'access', 'extension/oc_ext/module/oc_ext');
		 $this->model_user_user_group->addPermission($this->user->getGroupId(), 'modify', 'extension/oc_ext/module/oc_ext');
	 }
	 
	 protected function removeAccessRights() {
		 $this->load->model('user/user_group');
	 }

    public function index(): void {
        $this->load->language('extension/oc_ext/module/oc_ext');

        $this->document->setTitle($this->language->get('heading_title'));

        $this->load->model('extension/oc_ext/module/oc_ext');

        $data['breadcrumbs'] = [];

        $data['breadcrumbs'][] = [
            'text' => $this->language->get('text_home'),
            'href' => $this->url->link('common/dashboard', 'user_token=' . $this->session->data['user_token'])
        ];

        $data['breadcrumbs'][] = [
            'text' => $this->language->get('text_extension'),
            'href' => $this->url->link('marketplace/extension', 'user_token=' . $this->session->data['user_token'] . '&type=module')
        ];

        $data['breadcrumbs'][] = [
            'text' => $this->language->get('heading_title'),
            'href' => $this->url->link('extension/oc_ext/module/oc_ext', 'user_token=' . $this->session->data['user_token'])
        ];

        $data['save'] = $this->url->link('extension/oc_ext/module/oc_ext|save', 'user_token=' . $this->session->data['user_token']);
        $data['back'] = $this->url->link('marketplace/extension', 'user_token=' . $this->session->data['user_token'] . '&type=module');

        $data['module_'] = $this->config->get('module_oc_ext_status');

        $data['header'] = $this->load->controller('common/header');
        $data['column_left'] = $this->load->controller('common/column_left');
        $data['footer'] = $this->load->controller('common/footer');

        $this->response->setOutput($this->load->view('extension/oc_ext/module/oc_ext', $data));
    }

    public function save(): void {
        $this->load->language('extension/oc_ext/module/oc_ext');

        $json = [];

        if (!$this->user->hasPermission('modify', 'extension/oc_ext/module/oc_ext')) {
            $json['error'] = $this->language->get('error_permission');
        }

        if (!$json) {
            $this->load->model('setting/setting');

            $this->model_setting_setting->editSetting('module_oc_ext', $this->request->post);

            $json['success'] = $this->language->get('text_success');
        }

        $this->response->addHeader('Content-Type: application/json');
        $this->response->setOutput(json_encode($json));
    }
}
