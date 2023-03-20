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
});

