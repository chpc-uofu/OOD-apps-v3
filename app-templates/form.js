type="text/javascript"
//# sourceURL=form.js

// Strict mode for more secure code
'use strict';

// SETUP ---------------------------------------------------------------------------------------------------------------

// Get list of partitions and their associated GPUs
const gpuDataField = document.getElementById('batch_connect_session_context_gpudata');
const gpuData = gpuDataField.value.toString().substring(1, gpuDataField.value.length - 2);
const gpuDataHash = JSON.parse(gpuData);

// Mapping of GPU identifiers to their descriptions
const gpuMapping = gpuDataHash["gpu_name_mappings"].reduce((mapping, str) => {
    // Split string by last comma to separate description from GPU identifier
    const lastCommaIndex = str.lastIndexOf(',');
    const description = str.substring(0, lastCommaIndex).trim().replace(/^'|'$/g, '');
    const gpuId = str.substring(lastCommaIndex + 1).trim().replace(/^'|'$/g, '');

    // Assign description to GPU identifier in mapping object
    mapping[gpuId] = description;
    return mapping;
}, {});

// SET PARTITION LIMITS ------------------------------------------------------------------------------------------------

/**
 * Handles partition limits based on selected queue.
 * Adjusts maximum time, CPU, and memory values.
 * @param {string} selected_queue - The selected queue identifier.
 */
function partitionLimits(selected_queue) {
    // Get Form Fields
    const time = $('#batch_connect_session_context_bc_num_hours');
    const cpus = $('#batch_connect_session_context_num_cores');
    const mem = $('#batch_connect_session_context_memtask');

    // Define queue configurations
    const queueConfigs = {
        "notchpeak-shared-short:notchpeak-shared-short": { max_time: 8, max_cpu: 16, max_mem: 128 },
        "smithp-ash": { max_time: 168, max_cpu: 24, max_mem: 490 },
        "lp": { max_time: 336, max_cpu: 20, max_mem: 128 },
        "kp": { max_time: 336, max_cpu: 28, max_mem: 1000 },
        "np": { max_time: 336, max_cpu: 64, max_mem: 1000 }
    };

    // Find the appropriate queue configuration or use default values
    let config = Object.entries(queueConfigs).find(([key, _]) => selected_queue.includes(key));
    let { max_time, max_cpu, max_mem } = config ? config[1] : { max_time: 72, max_cpu: 64, max_mem: 764 };

    // Set and adjust form fields
    setFormField(time, max_time);
    setFormField(cpus, max_cpu);
    setFormField(mem, max_mem);
}

// Utility function for partitionLimits
function setFormField(field, maxValue) {
    if (field.val() > maxValue) {
        field.val(maxValue);
    }
    field.attr({ "max": maxValue });
}

// FILTER FUNCTIONS ----------------------------------------------------------------------------------------------------

/**
 * Updates GPU options based on the selected partition.
 */
function filterGPUOptions() {
    const selectedPartition = $('#batch_connect_session_context_custom_accpart').val().split(':')[1];
    const partitionString = gpuDataHash["gpu_partitions"].find(partition => partition.startsWith(selectedPartition + ','));

    const gpuSelect = $('#batch_connect_session_context_gpu_type');
    gpuSelect.empty(); // Clear existing options

    // Always add a 'none' option
    gpuSelect.append(new Option('none', 'none'));

    if (partitionString) {
        const availableGPUs = partitionString.split(',').slice(1).map(gpu => gpu.trim());

        if (availableGPUs.length > 0) {
            // Add 'any' option if GPUs are available
            gpuSelect.append(new Option('any', 'any'));

            // Add available GPUs as options
            availableGPUs.forEach(gpu => {
                if (gpuMapping[gpu]) // Check for mapping
                    gpuSelect.append(new Option(gpuMapping[gpu], gpu));
            });
            gpuSelect.parent().show(); // Show GPU selection field
        } else {
            gpuSelect.parent().show(); // Still show field with 'none' option
        }
    } else {
        gpuSelect.parent().show(); // Show field with only 'none' option if partition not found
    }
}

/**
 * Helper function to set default GPU option on partition change.
 */
function setDefaultGPU() {
    // Get GPU select element
    const gpuSelect = document.getElementById('batch_connect_session_context_gpu_type');
    gpuSelect.selectedIndex = 0;
}

/**
 * Filters account and partition options based on cluster selection.
 */
function filterAccountPartitionOptions() {
    // Get selected value from cluster dropdown
    const selectedCluster = document.getElementById('batch_connect_session_context_cluster').value;

    // Get account:partition select element
    const accountPartitionSelect = document.getElementById('batch_connect_session_context_custom_accpart');

    // Get all options within account:partition select
    const options = accountPartitionSelect.options;

    // Define mapping for cluster names and acronyms
    const clusterAcronyms = {
        'ash': 'ash',
        'kingspeak': 'kp',
        'lonepeak': 'lp',
        'notchpeak': 'np'
    };

    // Loop over options and hide those that do not match selected cluster
    for (let i = 0; i < options.length; i++) {
        const option = options[i];

        // Determine if the option value should be visible
        const isOptionVisible = option.value.indexOf(selectedCluster) >= 0 ||
            (clusterAcronyms[selectedCluster] && option.value.indexOf(clusterAcronyms[selectedCluster]) >= 0);

        // Set display style based on whether option should be visible
        option.style.display = isOptionVisible ? 'block' : 'none';
    }
    // Reset advanced options for cluster change
    toggleAdvancedOptions();
}

/**
 * Helper function to set a default partition on cluster change.
 */
function setDefaultPartition() {
    // Get account:partition select element
    const accountPartitionSelect = document.getElementById('batch_connect_session_context_custom_accpart');
    const options = accountPartitionSelect.options;

    // Iterate through options to find first one not hidden
    for (let i = 0; i < options.length; i++) {
        if (options[i].style.display !== 'none') {
            // Set first available option as selected
            accountPartitionSelect.selectedIndex = i;
            return;
        }
    }
}

// ADVANCED OPTIONS ----------------------------------------------------------------------------------------------------

/**
 * Toggles the visibility of advanced options in the form.
 * It shows or hides various input fields based on the state of their corresponding checkboxes
 * and the values of the input fields themselves.
 */
function toggleAdvancedOptions() {
    // Cache jQuery selectors for elements to improve performance
    const elements = {
        memtask: $('#batch_connect_session_context_memtask'),
        gpuType: $('#batch_connect_session_context_gpu_type').length > 0 ? $('#batch_connect_session_context_gpu_type') : null,
        gpuCount: $('#batch_connect_session_context_gpu_count').length > 0 ? $('#batch_connect_session_context_gpu_count') : null,
        nodelist: $('#batch_connect_session_context_nodelist'),
        constraint: $('#batch_connect_session_context_constraint'),
        additionalEnvironment: $('#batch_connect_session_context_additional_environment'),
        numNodes: $('#batch_connect_session_context_num_nodes').length > 0 ? $('#batch_connect_session_context_num_nodes') : null,
        checkboxes: {
            memtask: $('#batch_connect_session_context_memtask_checkbox'),
            gpu: $('#batch_connect_session_context_gpu_checkbox').length > 0 ? $('#batch_connect_session_context_gpu_checkbox') : null,
            addEnv: $('#batch_connect_session_context_add_env_checkbox'),
            nodelist: $('#batch_connect_session_context_nodelist_checkbox'),
            constraint: $('#batch_connect_session_context_constraint_checkbox'),
            nodes: $('#batch_connect_session_context_nodes_checkbox').length > 0 ? $('#batch_connect_session_context_nodes_checkbox') : null
        },
        advancedOptions: $('#batch_connect_session_context_advanced_options')
    };

    // Helper function to toggle visibility
    function toggleVisibility(element, condition) {
        if (element) {
            condition ? element.parent().show() : element.parent().hide();
        }
    }

    // Check if advanced options checkbox is checked
    if (elements.advancedOptions.is(':checked')) {
        toggleVisibility(elements.checkboxes.memtask, true);
        toggleVisibility(elements.memtask, elements.memtask.val() !== "0" && elements.memtask.val() !== "");

        // Logic for GPU fields, if applicable
        if (elements.gpuType && elements.gpuCount && elements.checkboxes.gpu) {
            toggleVisibility(elements.checkboxes.gpu, true);
            const isGPUSelected = elements.gpuType.val() !== "none";
            toggleVisibility(elements.gpuType, isGPUSelected);
            toggleVisibility(elements.gpuCount, isGPUSelected);
        }

        const isNodelistSelected = elements.nodelist.val() !== "" || elements.checkboxes.nodelist.is(':checked');
        toggleVisibility(elements.nodelist, isNodelistSelected);

        toggleVisibility(elements.additionalEnvironment, elements.additionalEnvironment.val() !== "");
        toggleVisibility(elements.constraint, elements.constraint.val() !== "");

        // Logic for nodes field, if applicable
        if (elements.numNodes && elements.checkboxes.nodes) {
            let shouldShowNodes = elements.checkboxes.nodes.is(':checked') || elements.numNodes.val() !== "1";
            toggleVisibility(elements.numNodes, shouldShowNodes);
            toggleVisibility(elements.checkboxes.nodes, true);

            if (!elements.checkboxes.nodes.is(':checked') && elements.numNodes.val() !== "1") {
                elements.checkboxes.nodes.prop('checked', true);
            }
        }

        toggleVisibility(elements.checkboxes.nodelist, true);
        toggleVisibility(elements.checkboxes.addEnv, true);
        toggleVisibility(elements.checkboxes.constraint, true);
    } else {
        // Determine if all fields are empty or in default state
        let allEmpty = elements.memtask.val() === "0" &&
            elements.nodelist.val() === "" &&
            elements.additionalEnvironment.val() === "" &&
            elements.constraint.val() === "";
        if (elements.gpuType) {
            allEmpty = allEmpty && elements.gpuType.val() === "none";
        }
        if (elements.numNodes) {
            allEmpty = allEmpty && elements.numNodes.val() === "1";
        }

        if (allEmpty) {
            // Hide all fields and uncheck all checkboxes if all fields are empty
            Object.values(elements.checkboxes).forEach(checkbox => {
                if (checkbox) {
                    toggleVisibility(checkbox, false);
                    checkbox.prop('checked', false);
                }
            });

            toggleVisibility(elements.memtask, false);
            toggleVisibility(elements.gpuType, false);
            toggleVisibility(elements.gpuCount, false);
            toggleVisibility(elements.nodelist, false);
            toggleVisibility(elements.additionalEnvironment, false);
            toggleVisibility(elements.constraint, false);
            if (elements.numNodes) {
                toggleVisibility(elements.numNodes, false);
            }
        } else {
            elements.advancedOptions.prop('checked', true);
        }
    }
}

// TOGGLE FUNCTIONS ----------------------------------------------------------------------------------------------------

/**
 * Toggles the visibility of additional environment input field in the form.
 * It shows or hides the field based on the state of its corresponding checkbox
 * and the value of the input field itself.
 */
function toggleAddEnv() {
    let additional_environment = $('#batch_connect_session_context_additional_environment');
    let add_env_checkbox = $('#batch_connect_session_context_add_env_checkbox');

    // Determine whether to show or hide additional environment field
    let shouldShow = add_env_checkbox.is(':checked') || additional_environment.val() !== "";

    // Toggle visibility of additional environment field
    additional_environment.parent().toggle(shouldShow);

    // Ensure checkbox is checked if field is non-empty
    if (!add_env_checkbox.is(':checked') && additional_environment.val() !== "") {
        add_env_checkbox.prop('checked', true);
    }
}

/**
 * Toggles the visibility of nodelist input field in the form.
 * It shows or hides the field based on the state of its corresponding checkbox
 * and the value of the input field itself.
 */
function toggleNodelist() {
    let nodelist = $('#batch_connect_session_context_nodelist');
    let nodelist_checkbox = $('#batch_connect_session_context_nodelist_checkbox');

    // Determine whether to show or hide nodelist field
    let shouldShow = nodelist_checkbox.is(':checked') || nodelist.val() !== "";

    // Toggle visibility of nodelist field
    nodelist.parent().toggle(shouldShow);

    // Ensure checkbox is checked if field is non-empty
    if (!nodelist_checkbox.is(':checked') && nodelist.val() !== "") {
        nodelist_checkbox.prop('checked', true);
    }
}

/**
 * Toggles the visibility of memtask input field in the form.
 * It shows or hides the field based on the state of its corresponding checkbox
 * and the value of the input field itself.
 */
function toggleMemtask() {
    let memtask = $('#batch_connect_session_context_memtask');
    let memtask_checkbox = $('#batch_connect_session_context_memtask_checkbox');

    // Determine whether to show or hide memtask field
    let shouldShow = memtask_checkbox.is(':checked') || (memtask.val() !== "0" && memtask.val() !== "");

    // Toggle visibility of memtask field
    memtask.parent().toggle(shouldShow);

    // Ensure checkbox is checked if field is non-empty and not zero
    if (!memtask_checkbox.is(':checked') && memtask.val() !== "0" && memtask.val() !== "") {
        memtask_checkbox.prop('checked', true);
    }
}

/**
 * Toggles the visibility of GPU type and count fields in the form.
 * It shows or hides these fields based on the state of the GPU checkbox
 * and the value of the GPU type field.
 */
function toggleGPU() {
    let gpu_type = $('#batch_connect_session_context_gpu_type');
    let gpu_count = $('#batch_connect_session_context_gpu_count');
    let gpu_checkbox = $('#batch_connect_session_context_gpu_checkbox');

    // Determine whether to show or hide GPU type and count fields
    let showGPUType = gpu_checkbox.is(':checked') || gpu_type.val() !== "none";
    let showGPUCount = showGPUType && gpu_type.val() !== "none";

    // Toggle visibility of GPU type field
    gpu_type.parent().toggle(showGPUType);

    // Toggle visibility of GPU count field
    gpu_count.parent().toggle(showGPUCount);

    // If checkbox is not checked and GPU type is not 'none', check checkbox
    if (!gpu_checkbox.is(':checked') && gpu_type.val() !== "none") {
        gpu_checkbox.prop('checked', true);
    }
}

/**
 * Toggles the visibility of constraint input field in the form.
 * It shows or hides the field based on the state of its corresponding checkbox
 * and the value of the input field itself.
 */
function toggleConstraint() {
    let constraint = $('#batch_connect_session_context_constraint');
    let constraint_checkbox = $('#batch_connect_session_context_constraint_checkbox');

    // Determine whether to show or hide constraint field
    let shouldShow = constraint_checkbox.is(':checked') || constraint.val() !== "";

    // Toggle visibility of constraint field
    constraint.parent().toggle(shouldShow);

    // Ensure checkbox is checked if field is non-empty
    if (!constraint_checkbox.is(':checked') && constraint.val() !== "") {
        constraint_checkbox.prop('checked', true);
    }
}

/**
 * Toggles the visibility of nodes input field in the form.
 * It shows or hides the field based on the state of its corresponding checkbox
 * and the value of the input field itself.
 */
function toggleNodes() {
    let num_nodes = $('#batch_connect_session_context_num_nodes');
    let nodes_checkbox = $('#batch_connect_session_context_nodes_checkbox');

    // Determine whether to show or hide nodes field
    let shouldShow = nodes_checkbox.is(':checked') || num_nodes.val() !== "1";

    // Toggle visibility of nodes field
    num_nodes.parent().toggle(shouldShow);

    // Ensure checkbox is checked if field value is not "1"
    if (!nodes_checkbox.is(':checked') && num_nodes.val() !== "1") {
        nodes_checkbox.prop('checked', true);
    }
}

// DOCUMENT ------------------------------------------------------------------------------------------------------------

/**
 * Initializes form by setting up event listeners and default states when DOM is ready.
 */
$(document).ready(function () {
    // jQuery selectors
    const selectors = {
        queue: $('#batch_connect_session_context_custom_accpart'),
        cluster: $('#batch_connect_session_context_cluster'),
        memtaskCheckbox: $('#batch_connect_session_context_memtask_checkbox'),
        gpuCheckbox: $('#batch_connect_session_context_gpu_checkbox'),
        advancedOptionsCheckbox: $('#batch_connect_session_context_advanced_options'),
        nodelistCheckbox: $('#batch_connect_session_context_nodelist_checkbox'),
        addEnvCheckbox: $('#batch_connect_session_context_add_env_checkbox'),
        constraintCheckbox: $('#batch_connect_session_context_constraint_checkbox'),
        nodesCheckbox: $('#batch_connect_session_context_nodes_checkbox')
    };

    // Run initial filters and setup
    filterAccountPartitionOptions();
    filterGPUOptions();
    partitionLimits(selectors.queue.val());

    // Add change event listeners
    selectors.queue.on('change', function () {
        partitionLimits($(this).val());
        filterGPUOptions();
        toggleGPU();
        setDefaultGPU();
    });

    selectors.cluster.on('change', function () {
        filterAccountPartitionOptions();
        setDefaultPartition();
        filterGPUOptions();
        setDefaultGPU();
    });

    // Toggle functions for elements
    const toggleFunctions = {
        memtaskCheckbox: toggleMemtask,
        gpuCheckbox: toggleGPU,
        advancedOptionsCheckbox: toggleAdvancedOptions,
        nodelistCheckbox: toggleNodelist,
        addEnvCheckbox: toggleAddEnv,
        constraintCheckbox: toggleConstraint,
        nodesCheckbox: toggleNodes
    };

    Object.entries(toggleFunctions).forEach(([key, func]) => {
        selectors[key].change(func);
    });

    // Set initial state
    Object.values(toggleFunctions).forEach(fn => fn());
});