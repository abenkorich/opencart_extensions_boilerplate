<?php
namespace Opencart\Catalog\Controller\Extension\oc_ext\Module;
class oc_ext extends \Opencart\System\Engine\Controller {
    public function index($setting) {
        $this->load->language('extension/oc_ext/module/oc_ext');

        $this->load->model('extension/oc_ext/module/oc_ext');

        $data['heading_title'] = $this->language->get('heading_title');

        return $this->load->view('extension/oc_ext/module/oc_ext', $data);
    }
}
