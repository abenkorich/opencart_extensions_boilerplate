#!/bin/bash

# Check if a module name was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <module_name>"
    exit 1
fi

MODULE_NAME=$1
MODULE_NAME_LOWER=$(echo $MODULE_NAME | tr '[:upper:]' '[:lower:]')
MODULE_NAME_UPPER=$(echo $MODULE_NAME | tr '[:lower:]' '[:upper:]')

# Create directory structure
mkdir -p $MODULE_NAME_LOWER/{admin/{controller/module,language/en-gb/module,model/module,view/{javascript/$MODULE_NAME_LOWER-next-app/,stylesheet,template/module}},catalog/{controller/module,language/en-gb/module,model/module,view/{javascript,stylesheet,template/module}}}

# Create admin files
cat > $MODULE_NAME_LOWER/admin/controller/module/$MODULE_NAME_LOWER.php << EOL
<?php
namespace Opencart\Admin\Controller\Extension\\$MODULE_NAME\Module;
class $MODULE_NAME extends \Opencart\System\Engine\Controller {
    
    	 protected string \$method_separator; 
	 protected \$conf  = array();  
	
	 // OK
	 public function __construct(\Opencart\System\Engine\Registry \$registry) {
		 parent::__construct(\$registry);
		 
		 \$this->method_separator = version_compare(VERSION,'4.0.2.0','>=') ? '.' : '|';
	
		 //\$this->config->load('benadev/bd_extensions');
		 //\$this->conf = \$this->config->get('config');
		 //\$API_ENDPOINT = \$this->conf['\$API_ENDPOINT'];
		 
		 \$this->load->language('extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER');
		 \$this->document->setTitle(\$this->language->get('text_title'));
		 
		 \$this->load->model('extension/benadev/module/bd_modules');
		 \$this->load->model('extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER');
	 }
	 
	 public function checkCoreModule(){
		 
		 \$this->load->model('setting/extension');
		 
		 \$installed_modules = \$this->model_setting_extension->getInstalls();
		 \$bd_modules = \$this->model_setting_extension->getExtensionByCode('module', 'bd_modules');
		 \$bd_modules_event = \$this->model_setting_event->getEventByCode('bd_modules');
	
		 // check if the bd mcore module is installed and the vent is created
		 if (\$bd_modules && \$bd_modules_event) {
			 return true;
		 } else {
			 return false;
		 }
	 }
	 
	 // Ext Installation
	 public function installDB() {
		 \$this->model_extension_$MODULE_NAME_LOWER_module_$MODULE_NAME_LOWER->installDBTables();
	 }
	 
	 // Ext Installation
	 public function install() {
		 
		 \$this->load->model('setting/event');
		 \$this->model_extension_$MODULE_NAME_LOWER_module_$MODULE_NAME_LOWER->installDBTables();
		 
		 if ( \$this->checkCoreModule() ) {
			 if (version_compare(VERSION,'4.0.1.0','>=')) {
				 \$data = [
					 'code'        => '$MODULE_NAME_LOWER',
					 'description' => 'A Drag and Drop responsive layout designer for opencart',
					 'trigger'     => 'admin/view/common/column_left/before',
					 'action'      => 'extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER' . \$this->method_separator . 'eventHandler',
					 'status'      => true,
					 'sort_order'  => 0
				 ];
				 \$this->model_setting_event->addEvent(\$data);
			 } else {
				 \$this->model_setting_event->addEvent('$MODULE_NAME_LOWER','','admin/view/common/column_left/before','extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER'.\$this->method_separator.'eventHandler');
			 }
			 \$this->generateMenu();
			 \$this->addAccessRights();
		 } else {
			 return "Benadev core module need to be installed first";
		 }
	 }
	
	 // Ext DEsinstallation
	 public function uninstall() {
		 \$this->load->model('setting/event');
		 \$this->model_setting_event->deleteEventByCode('$MODULE_NAME_LOWER');
		 \$this->model_extension_benadev_module_bd_modules->deleteModule('$MODULE_NAME_LOWER');
		 \$this->removeAccessRights();
	 }
	
	 // Add to the left menu event 
	 public function eventHandler(\$route, &\$data){
		 \$this->generateMenu();
	 }
	 
	 public function generateMenu(){
	
		 \$this->load->model('setting/setting');
		 \$this->load->language('extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER');
		 
		 \$menu = array();
			 
		 // setting sub menu
		 if (\$this->user->hasPermission('access', 'extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER')) {
			 \$menu = [
				 'name'	   => \$this->language->get('text_title'),
				 'href'     => \$this->url->link('extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER'.\$this->method_separator.'getList', 'user_token='),
				 'children' => []
			 ];
		 }
	
		 \$data['name'] = '$MODULE_NAME_LOWER';
		 \$data['parent'] = '';
		 \$data['menu_items'] = \$menu;
		 \$data['status'] = '1';
		 
		 \$this->model_extension_benadev_module_bd_modules->addModule(\$data);
	
	 }
	 
	 protected function addAccessRights() {
		 \$this->load->model('user/user_group');
		 \$this->model_user_user_group->addPermission(\$this->user->getGroupId(), 'access', 'extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER');
		 \$this->model_user_user_group->addPermission(\$this->user->getGroupId(), 'modify', 'extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER');
	 }
	 
	 protected function removeAccessRights() {
		 \$this->load->model('user/user_group');
	 }

    public function index(): void {
        \$this->load->language('extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER');

        \$this->document->setTitle(\$this->language->get('heading_title'));

        \$this->load->model('extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER');

        \$data['breadcrumbs'] = [];

        \$data['breadcrumbs'][] = [
            'text' => \$this->language->get('text_home'),
            'href' => \$this->url->link('common/dashboard', 'user_token=' . \$this->session->data['user_token'])
        ];

        \$data['breadcrumbs'][] = [
            'text' => \$this->language->get('text_extension'),
            'href' => \$this->url->link('marketplace/extension', 'user_token=' . \$this->session->data['user_token'] . '&type=module')
        ];

        \$data['breadcrumbs'][] = [
            'text' => \$this->language->get('heading_title'),
            'href' => \$this->url->link('extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER', 'user_token=' . \$this->session->data['user_token'])
        ];

        \$data['save'] = \$this->url->link('extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER|save', 'user_token=' . \$this->session->data['user_token']);
        \$data['back'] = \$this->url->link('marketplace/extension', 'user_token=' . \$this->session->data['user_token'] . '&type=module');

        \$data['module_$MODULE_NAME_LOWER_status'] = \$this->config->get('module_${MODULE_NAME_LOWER}_status');

        \$data['header'] = \$this->load->controller('common/header');
        \$data['column_left'] = \$this->load->controller('common/column_left');
        \$data['footer'] = \$this->load->controller('common/footer');

        \$this->response->setOutput(\$this->load->view('extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER', \$data));
    }

    public function save(): void {
        \$this->load->language('extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER');

        \$json = [];

        if (!\$this->user->hasPermission('modify', 'extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER')) {
            \$json['error'] = \$this->language->get('error_permission');
        }

        if (!\$json) {
            \$this->load->model('setting/setting');

            \$this->model_setting_setting->editSetting('module_$MODULE_NAME_LOWER', \$this->request->post);

            \$json['success'] = \$this->language->get('text_success');
        }

        \$this->response->addHeader('Content-Type: application/json');
        \$this->response->setOutput(json_encode(\$json));
    }
}
EOL

cat > $MODULE_NAME_LOWER/admin/language/en-gb/module/$MODULE_NAME_LOWER.php << EOL
<?php
// Heading
\$_['heading_title']    = '$MODULE_NAME';

// Text
\$_['text_extension']   = 'Extensions';
\$_['text_success']     = 'Success: You have modified $MODULE_NAME module!';
\$_['text_edit']        = 'Edit $MODULE_NAME Module';

// Entry
\$_['entry_status']     = 'Status';

// Error
\$_['error_permission'] = 'Warning: You do not have permission to modify $MODULE_NAME module!';
EOL

cat > $MODULE_NAME_LOWER/admin/model/module/$MODULE_NAME_LOWER.php << EOL
<?php
namespace Opencart\Admin\Model\Extension\\$MODULE_NAME\Module;
class $MODULE_NAME extends \Opencart\System\Engine\Model {
    public function installDBTables() {

    }
}
EOL

cat > $MODULE_NAME_LOWER/admin/view/template/module/$MODULE_NAME_LOWER.twig << EOL
{{ header }}{{ column_left }}
<div id="content">
  <div class="page-header">
    <div class="container-fluid">
      <div class="float-end">
        <button type="submit" form="form-module" data-bs-toggle="tooltip" title="{{ button_save }}" class="btn btn-primary"><i class="fa-solid fa-save"></i></button>
        <a href="{{ back }}" data-bs-toggle="tooltip" title="{{ button_back }}" class="btn btn-light"><i class="fa-solid fa-reply"></i></a>
      </div>
      <h1>{{ heading_title }}</h1>
      <ol class="breadcrumb">
        {% for breadcrumb in breadcrumbs %}
          <li class="breadcrumb-item"><a href="{{ breadcrumb.href }}">{{ breadcrumb.text }}</a></li>
        {% endfor %}
      </ol>
    </div>
  </div>
  <div class="container-fluid">
    <div class="card">
      <div class="card-header"><i class="fa-solid fa-pencil"></i> {{ text_edit }}</div>
      <div class="card-body">
        <form id="form-module" action="{{ save }}" method="post" data-oc-toggle="ajax">
          <div class="row mb-3">
            <label for="input-status" class="col-sm-2 col-form-label">{{ entry_status }}</label>
            <div class="col-sm-10">
              <div class="form-check form-switch form-switch-lg">
                <input type="hidden" name="module_${MODULE_NAME_LOWER}_status" value="0"/>
                <input type="checkbox" name="module_${MODULE_NAME_LOWER}_status" value="1" id="input-status" class="form-check-input"{% if module_${MODULE_NAME_LOWER}_status %} checked{% endif %}/>
              </div>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
{{ footer }}
EOL

# Create catalog files
cat > $MODULE_NAME_LOWER/catalog/controller/module/$MODULE_NAME_LOWER.php << EOL
<?php
namespace Opencart\Catalog\Controller\Extension\\$MODULE_NAME\Module;
class $MODULE_NAME extends \Opencart\System\Engine\Controller {
    public function index(\$setting) {
        \$this->load->language('extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER');

        \$this->load->model('extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER');

        \$data['heading_title'] = \$this->language->get('heading_title');

        return \$this->load->view('extension/$MODULE_NAME_LOWER/module/$MODULE_NAME_LOWER', \$data);
    }
}
EOL

cat > $MODULE_NAME_LOWER/catalog/language/en-gb/module/$MODULE_NAME_LOWER.php << EOL
<?php
// Heading
\$_['heading_title'] = '$MODULE_NAME';

// Text
\$_['text_tax']      = 'Ex Tax:';
EOL

cat > $MODULE_NAME_LOWER/catalog/model/module/$MODULE_NAME_LOWER.php << EOL
<?php
namespace Opencart\Catalog\Model\Extension\\$MODULE_NAME\Module;
class $MODULE_NAME extends \Opencart\System\Engine\Model {
    public function method() {
        // Add your catalog model methods here
    }
}
EOL

cat > $MODULE_NAME_LOWER/catalog/view/template/module/$MODULE_NAME_LOWER.twig << EOL
<h3>{{ heading_title }}</h3>
<div class="row">
  <p>Your $MODULE_NAME content goes here.</p>
</div>
EOL

# Create empty JavaScript files
touch $MODULE_NAME_LOWER/admin/view/javascript/$MODULE_NAME_LOWER.js
touch $MODULE_NAME_LOWER/catalog/view/javascript/$MODULE_NAME_LOWER.js

# Create empty CSS files
touch $MODULE_NAME_LOWER/admin/view/stylesheet/$MODULE_NAME_LOWER.css
touch $MODULE_NAME_LOWER/catalog/view/stylesheet/$MODULE_NAME_LOWER.css

# Create install.json
cat > $MODULE_NAME_LOWER/install.json << EOL
{
    "name": "$MODULE_NAME",
    "date": "$(date +%Y_%m_%d)",
    "version": "1.0",
    "author": "BenaDev",
    "link": "http://www.bena.dev"
}
EOL

zip -r $MODULE_NAME_LOWER.ocmod.zip ./$MODULE_NAME_LOWER/* -x "**/node_modules/*"  "**/.next/*"

echo "**************************************************************************************"
echo "$MODULE_NAME module boilerplate with Next.js app has been generated successfully!"
echo "**************************************************************************************"
echo "Next steps:"
echo "  1. Copy the $MODULE_NAME_LOWER directory to your OpenCart extension directory."
echo "  2. Install the module from the OpenCart admin panel."
echo "  3. Configure and customize the module as needed."
echo "  4. Add your custom logic to the model files, JavaScript files, and stylesheets."
echo "  5. To work on the Next.js app:"
echo "    a. Navigate to $MODULE_NAME_LOWER/admin/view/javascript/$MODULE_NAME_LOWER-next-app"
echo "    b. Run 'npm install' to install dependencies"
echo "    c. Use 'npm run dev' to start the development server"
echo "    d. Build the app with 'npm run build' when ready to deploy"
echo "**************************************************************************************"
