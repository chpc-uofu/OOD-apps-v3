 type="text/javascript"
 //# sourceURL=form.js

'use strict'

/*
 * Function to handle partition limitations
 */

function partition_limits(selected_queue) {

	// Get Form Fields
	var accpart = $('#batch_connect_session_context_custom_accpart');
	var time = $('#batch_connect_session_context_bc_num_hours');
	var cpus = $('#batch_connect_session_context_num_cores');
	var mem = $('#batch_connect_session_context_memtask');

	// Get Default Max Values
	var max_time = time.attr("max");
	var max_cpu = cpus.attr("max");
	var max_mem = mem.attr("max");

	if (selected_queue === "notchpeak-shared-short:notchpeak-shared-short") {

		max_time = 8;
		max_cpu = 16;
		max_mem = 128;
	}
	else if (selected_queue.includes("smithp-ash")) {

		max_time = 168;
		max_cpu = 24;
		max_mem = 490;
	}
	else if (selected_queue.includes("lp") ) {

		max_time = 336;
		max_cpu = 20;
		max_mem = 128;
	}
	else if (selected_queue.includes("kp") ) {

		max_time = 336;
		max_cpu = 28;
		max_mem = 1000;
	}
	else if (selected_queue.includes("np") ) {

		max_time = 336;
		max_cpu = 64;
		max_mem = 1000;
	}
	else {

		max_time = 72;
		max_cpu = 64;
		max_mem = 764;
	}

	// Handle Max Time Changes
	if (time.val() > max_time) {
		time.val(max_time)
	}
	time.attr({ "max": max_time });

	// Handle Max CPU Changes
	if (cpus.val() > max_cpu) {
		cpus.val(max_cpu)
	}
	cpus.attr({ "max": max_cpu });

	// Handle Max Mem Changes
	if (mem.val() > max_mem) {
		mem.val(max_mem)
	}
	mem.attr({ "max": max_mem });
}

function toggle_advanced_options() {
  let memtask = $('#batch_connect_session_context_memtask');
  let nodelist = $('#batch_connect_session_context_nodelist');
  let constraint = $('#batch_connect_session_context_constraint');
  let additional_environment = $('#batch_connect_session_context_additional_environment');
  let memtask_checkbox = $('#batch_connect_session_context_memtask_checkbox');
  let add_env_checkbox = $('#batch_connect_session_context_add_env_checkbox');
  let nodelist_checkbox = $('#batch_connect_session_context_nodelist_checkbox');
  let constraint_checkbox = $('#batch_connect_session_context_constraint_checkbox');
  let advanced_options = document.getElementById("batch_connect_session_context_advanced_options");

  if(advanced_options.checked === true)  {
      memtask_checkbox.parent().show();
      if (memtask[0].value === "0" || memtask[0].value === "") {
        memtask.parent().hide();
      } else {
        memtask.parent().show();
      }
      if (nodelist[0].value === "") {
        if (nodelist_checkbox[0].checked === true) {
          nodelist.parent().show();
	}
      } else {
          nodelist.parent().show();
      }
      if (additional_environment[0].value === "") {
        additional_environment.parent().hide();
      } else {
        additional_environment.parent().show();
      }
      if (constraint[0].value === "") {
        constraint.parent().hide();
      } else {
        constraint.parent().show();
      }
      nodelist_checkbox.parent().show();
      add_env_checkbox.parent().show();
      constraint_checkbox.parent().show();
  } else {
      if (( memtask[0].value === "0" || memtask[0].value === "" ) && ( nodelist[0].value === "" ) && ( additional_environment[0].value === "" ) && ( constraint[0].value === "")) {
      memtask_checkbox.parent().hide();
      memtask.parent().hide();
      nodelist.parent().hide();
      additional_environment.parent().hide();
      constraint.parent().hide();
      nodelist_checkbox.parent().hide();
      add_env_checkbox.parent().hide();
      constraint_checkbox.parent().hide();
      memtask_checkbox[0].checked = false;
      nodelist_checkbox[0].checked = false;
      add_env_checkbox[0].checked = false;
      constraint_checkbox[0].checked = false;
      } else {
          advanced_options.checked = true;
      }
  }
}

function toggle_add_env() {
  let additional_environment = $('#batch_connect_session_context_additional_environment');
  let add_env_checkbox = document.getElementById("batch_connect_session_context_add_env_checkbox");

  if(add_env_checkbox.checked === true)  {
      additional_environment.parent().show();
  } else {
      if (additional_environment[0].value === "") {
        additional_environment.parent().hide();
      } else {
        add_env_checkbox.checked = true;
        additional_environment.parent().show();
      }
  }
}

function toggle_nodelist() {
  let nodelist = $('#batch_connect_session_context_nodelist');
  let nodelist_checkbox = document.getElementById("batch_connect_session_context_nodelist_checkbox");

  if(nodelist_checkbox.checked === true)  {
      nodelist.parent().show();
  } else {
      if (nodelist[0].value === "") {
        nodelist.parent().hide();
      } else {
        nodelist_checkbox.checked = true;
        nodelist.parent().show();
      }
  }
}

function toggle_memtask() {
  let memtask = $('#batch_connect_session_context_memtask');
  let memtask_checkbox = document.getElementById("batch_connect_session_context_memtask_checkbox");

  if(memtask_checkbox.checked === true)  {
      memtask.parent().show();
  } else {
      if (memtask[0].value === "0" || memtask[0].value === "") {
        memtask.parent().hide();
      } else {
        memtask_checkbox.checked = true;
        memtask.parent().show();
      }
  }
}

function toggle_constraint() {
  let constraint = $('#batch_connect_session_context_constraint');
  let constraint_checkbox = document.getElementById("batch_connect_session_context_constraint_checkbox");

  if(constraint_checkbox.checked === true)  {
      constraint.parent().show();
  } else {
      if (constraint[0].value === "") {
        constraint.parent().hide();
      } else {
        constraint_checkbox.checked = true;
      }
  }
}

/*

 * Invoke the functions when the DOM is ready.
 */

$(document).ready(function () {

	// Set Default Partition
	// $('select').find('option[value="notchpeak-shared-short:notchpeak-shared-short"]').attr('selected', 'selected');

	// Handle Partition Specific Settings
	let queue = $('#batch_connect_session_context_custom_accpart');
	partition_limits(queue[0].value);
	queue.change(function () {
		partition_limits(queue[0].value);
	})
        // toggle memtask on form refresh
        let install_trigger5 = $('#batch_connect_session_context_memtask_checkbox');
        install_trigger5.change(toggle_memtask);
        const form5 = document.getElementById("new_batch_connect_session_context");
        toggle_memtask();
        // toggle advanced options on form refresh
        let install_trigger = $('#batch_connect_session_context_advanced_options');
        install_trigger.change(toggle_advanced_options);
        const form = document.getElementById("new_batch_connect_session_context");
        toggle_advanced_options();
        // toggle nodelist on form refresh
        let install_trigger3 = $('#batch_connect_session_context_nodelist_checkbox');
        install_trigger3.change(toggle_nodelist);
        const form3 = document.getElementById("new_batch_connect_session_context");
        toggle_nodelist();
        // toggle additional environment on form refresh
        let install_trigger2 = $('#batch_connect_session_context_add_env_checkbox');
        install_trigger2.change(toggle_add_env);
        const form2 = document.getElementById("new_batch_connect_session_context");
        toggle_add_env();
        // toggle constraints on form refresh
        let install_trigger4 = $('#batch_connect_session_context_constraint_checkbox');
        install_trigger4.change(toggle_constraint);
        const form4 = document.getElementById("new_batch_connect_session_context");
        toggle_constraint();
});

