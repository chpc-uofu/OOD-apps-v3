type="text/javascript"
//# sourceURL=form.js

'use strict';

// SETUP ---------------------------------------------------------------------------------------------------------------

/**
 * Retrieves GPU data from the form and parses it into a usable format.
 */
const gpuDataField = document.getElementById('batch_connect_session_context_gpudata');
const gpuData = gpuDataField.value.toString().substring(1, gpuDataField.value.length - 2);
const gpuDataHash = JSON.parse(gpuData);

/**
 * Maps GPU identifiers to their descriptions.
 */
const gpuMapping = gpuDataHash["gpu_name_mappings"].reduce((mapping, str) => {
    const lastCommaIndex = str.lastIndexOf(',');
    const description = str.substring(0, lastCommaIndex).trim().replace(/^'|'$/g, '');
    const gpuId = str.substring(lastCommaIndex + 1).trim().replace(/^'|'$/g, '');
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
    const time = $('#batch_connect_session_context_bc_num_hours');
    const cpus = $('#batch_connect_session_context_num_cores');
    const mem = $('#batch_connect_session_context_memtask');

    const queueConfigs = {
        "notchpeak-shared-short:notchpeak-shared-short": { max_time: 8, max_cpu: 16, max_mem: 128 },
        "smithp-ash": { max_time: 168, max_cpu: 24, max_mem: 490 },
        "lp": { max_time: 336, max_cpu: 20, max_mem: 128 },
        "kp": { max_time: 336, max_cpu: 28, max_mem: 1000 },
        "np": { max_time: 336, max_cpu: 64, max_mem: 1000 }
    };

    let config = Object.entries(queueConfigs).find(([key, _]) => selected_queue.includes(key));
    let { max_time, max_cpu, max_mem } = config ? config[1] : { max_time: 72, max_cpu: 64, max_mem: 764 };

    setFormField(time, max_time);
    setFormField(cpus, max_cpu);
    setFormField(mem, max_mem);
}

/**
 * Utility function to set form field values and attributes.
 * @param {object} field - The form field element.
 * @param {number} maxValue - The maximum value to set.
 */
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

    gpuSelect.append(new Option('none', 'none'));

    if (partitionString) {
        const availableGPUs = partitionString.split(',').slice(1).map(gpu => gpu.trim());

        if (availableGPUs.length > 0) {
            gpuSelect.append(new Option('any', 'any'));
            availableGPUs.forEach(gpu => {
                if (gpuMapping[gpu]) 
                    gpuSelect.append(new Option(gpuMapping[gpu], gpu));
            });
            gpuSelect.parent().show();
        } else {
            gpuSelect.parent().show();
        }
    } else {
        gpuSelect.parent().show();
    }
}

/**
 * Sets the default GPU option on partition change.
 */
function setDefaultGPU() {
    const gpuSelect = document.getElementById('batch_connect_session_context_gpu_type');
    gpuSelect.selectedIndex = 0;
}

/**
 * Filters account and partition options based on cluster selection.
 */
function filterAccountPartitionOptions() {
    const selectedCluster = document.getElementById('batch_connect_session_context_cluster').value;
    const accountPartitionSelect = document.getElementById('batch_connect_session_context_custom_accpart');
    const options = accountPartitionSelect.options;

    const clusterAcronyms = {
        'ash': 'ash',
        'kingspeak': 'kp',
        'lonepeak': 'lp',
        'notchpeak': 'np'
    };

    for (let i = 0; i < options.length; i++) {
        const option = options[i];
        const isOptionVisible = option.value.indexOf(selectedCluster) >= 0 ||
            (clusterAcronyms[selectedCluster] && option.value.indexOf(clusterAcronyms[selectedCluster]) >= 0);
        option.style.display = isOptionVisible ? 'block' : 'none';
    }
    toggleAdvancedOptions();
}

/**
 * Sets the default partition on form load or cluster change.
 */
function setDefaultPartition(clusterChange) {
    const accountPartitionSelect = document.getElementById('batch_connect_session_context_custom_accpart');
    const options = accountPartitionSelect.options;
    
    // Allow for caching
    if (clusterChange || !accountPartitionSelect.value) {
        for (i = 0; i < options.length; i++) {
            if (options[i].style.display !== 'none') {
                accountPartitionSelect.selectedIndex = i;
                return;
            }
        }
    }
}

// ADVANCED OPTIONS ----------------------------------------------------------------------------------------------------

/**
 * Toggles the visibility of advanced options in the form.
 */
function toggleAdvancedOptions() {
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

    function toggleVisibility(element, condition) {
        if (element) {
            condition ? element.parent().show() : element.parent().hide();
        }
    }

    const showAdvanced = elements.advancedOptions.is(':checked');

    Object.values(elements.checkboxes).forEach(checkbox => {
        if (checkbox) toggleVisibility(checkbox, showAdvanced);
    });

    toggleVisibility(elements.memtask, showAdvanced && elements.checkboxes.memtask.is(':checked'));
    toggleVisibility(elements.nodelist, showAdvanced && elements.checkboxes.nodelist.is(':checked'));
    toggleVisibility(elements.additionalEnvironment, showAdvanced && elements.checkboxes.addEnv.is(':checked'));
    toggleVisibility(elements.constraint, showAdvanced && elements.checkboxes.constraint.is(':checked'));

    if (elements.gpuType && elements.gpuCount && elements.checkboxes.gpu) {
        toggleVisibility(elements.gpuType, showAdvanced && elements.checkboxes.gpu.is(':checked'));
        toggleVisibility(elements.gpuCount, showAdvanced && elements.checkboxes.gpu.is(':checked') && elements.gpuType.val() !== "none");
    }

    if (elements.numNodes && elements.checkboxes.nodes) {
        toggleVisibility(elements.numNodes, showAdvanced && elements.checkboxes.nodes.is(':checked'));
    }

    const isAnyAdvancedOptionNonDefault = 
        elements.memtask.val() !== "0" ||
        (elements.gpuType && elements.gpuType.val() !== "none") ||
        (elements.gpuCount && elements.gpuCount.val() !== "1") ||
        elements.nodelist.val() !== "" ||
        elements.constraint.val() !== "" ||
        elements.additionalEnvironment.val() !== "" ||
        (elements.numNodes && elements.numNodes.val() !== "1");

    elements.advancedOptions.prop('disabled', isAnyAdvancedOptionNonDefault);

    if (isAnyAdvancedOptionNonDefault && !showAdvanced) {
        elements.advancedOptions.prop('checked', true);
        toggleAdvancedOptions();
    }
}

// TOGGLE FUNCTIONS ----------------------------------------------------------------------------------------------------

/**
 * Toggles the visibility of the memory task field.
 */
function toggleMemtask() {
    let memtask = $('#batch_connect_session_context_memtask');
    let memtask_checkbox = $('#batch_connect_session_context_memtask_checkbox');

    let showMemtask = memtask_checkbox.is(':checked');
    memtask.parent().toggle(showMemtask);

    if (!showMemtask) {
        memtask.val('0');
    }

    memtask_checkbox.prop('disabled', memtask.val() !== '0' && memtask.val() !== '');
}

/**
 * Toggles the visibility of the GPU fields.
 */
function toggleGPU() {
    let gpu_type = $('#batch_connect_session_context_gpu_type');
    let gpu_count = $('#batch_connect_session_context_gpu_count');
    let gpu_checkbox = $('#batch_connect_session_context_gpu_checkbox');

    let showGPUFields = gpu_checkbox.is(':checked');
    gpu_type.parent().toggle(showGPUFields);

    let showGPUCount = showGPUFields && gpu_type.val() !== "none";
    gpu_count.parent().toggle(showGPUCount);

    if (!showGPUFields) {
        gpu_type.val('none');
        gpu_count.val('1');
    }

    gpu_checkbox.prop('disabled', gpu_type.val() !== "none" || gpu_count.val() !== '1');
}

/**
 * Toggles the visibility of the nodelist field.
 */
function toggleNodelist() {
    let nodelist = $('#batch_connect_session_context_nodelist');
    let nodelist_checkbox = $('#batch_connect_session_context_nodelist_checkbox');

    let showNodelist = nodelist_checkbox.is(':checked');
    nodelist.parent().toggle(showNodelist);

    if (!showNodelist) {
        nodelist.val('');
    }

    nodelist_checkbox.prop('disabled', nodelist.val() !== '');
}

/**
 * Toggles the visibility of the additional environment field.
 */
function toggleAddEnv() {
    let additional_environment = $('#batch_connect_session_context_additional_environment');
    let add_env_checkbox = $('#batch_connect_session_context_add_env_checkbox');

    let showAddEnv = add_env_checkbox.is(':checked');
    additional_environment.parent().toggle(showAddEnv);

    if (!showAddEnv) {
        additional_environment.val('');
    }

    add_env_checkbox.prop('disabled', additional_environment.val() !== '');
}

/**
 * Toggles the visibility of the constraint field.
 */
function toggleConstraint() {
    let constraint = $('#batch_connect_session_context_constraint');
    let constraint_checkbox = $('#batch_connect_session_context_constraint_checkbox');

    let showConstraint = constraint_checkbox.is(':checked');
    constraint.parent().toggle(showConstraint);

    if (!showConstraint) {
        constraint.val('');
    }

    constraint_checkbox.prop('disabled', constraint.val() !== '');
}

/**
 * Toggles the visibility of the number of nodes field.
 */
function toggleNodes() {
    let num_nodes = $('#batch_connect_session_context_num_nodes');
    let nodes_checkbox = $('#batch_connect_session_context_nodes_checkbox');

    let showNodes = nodes_checkbox.is(':checked');
    num_nodes.parent().toggle(showNodes);

    if (!showNodes) {
        num_nodes.val('1');
    }

    nodes_checkbox.prop('disabled', num_nodes.val() !== '1');
}

/**
 * Toggles the visibility of the custom environment field based on Python version.
 */
function toggleCustomEnvironment() {
    const pythonField = $('#batch_connect_session_context_python');
    const customEnvironment = $('#batch_connect_session_context_custom_environment');
    const customEnvironmentParent = customEnvironment.closest('.form-group');

    const showCustomEnv = pythonField.val() === 'custom';
    customEnvironmentParent.toggle(showCustomEnv);

    if (!showCustomEnv) {
        customEnvironment.val('');
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
        nodesCheckbox: $('#batch_connect_session_context_nodes_checkbox'),
        gpuType: $('#batch_connect_session_context_gpu_type'),
        gpuCount: $('#batch_connect_session_context_gpu_count'),
        memtask: $('#batch_connect_session_context_memtask'),
        nodelist: $('#batch_connect_session_context_nodelist'),
        addEnv: $('#batch_connect_session_context_additional_environment'),
        constraint: $('#batch_connect_session_context_constraint'),
        numNodes: $('#batch_connect_session_context_num_nodes'),
        numCores: $('#batch_connect_session_context_num_cores'),
        numHours: $('#batch_connect_session_context_bc_num_hours'),
        python: $('#batch_connect_session_context_python'),
        customEnvironment: $('#batch_connect_session_context_custom_environment')
    };

    // Function to reset advanced options to default values
    function resetAdvancedOptions() {
        selectors.memtaskCheckbox.prop('checked', false);
        selectors.gpuCheckbox.prop('checked', false);
        selectors.nodelistCheckbox.prop('checked', false);
        selectors.addEnvCheckbox.prop('checked', false);
        selectors.constraintCheckbox.prop('checked', false);
        selectors.nodesCheckbox.prop('checked', false);
        selectors.advancedOptionsCheckbox.prop('checked', false);

        selectors.memtask.val('0');
        selectors.gpuType.val('none');
        selectors.gpuCount.val('1');
        selectors.nodelist.val('');
        selectors.addEnv.val('');
        selectors.constraint.val('');
        selectors.numNodes.val('1');
        selectors.customEnvironment.val('');

        // Trigger change event on advanced options checkbox to update visibility
        selectors.advancedOptionsCheckbox.trigger('change');
    }

    // Function to handle form display based on selected cluster
    function handleClusterSelection(initialSetup) {
        const selectedCluster = selectors.cluster.val();
        const isSpecialCluster = selectedCluster.includes('frisco') || selectedCluster.includes('bristlecone');

        // Show/hide form elements based on cluster selection
        Object.entries(selectors).forEach(([key, selector]) => {
            // Always show these elements regardless of cluster
            if (key === 'numCores' || key === 'numHours' || key === 'cluster' || 
                key === 'python' || key === 'customEnvironment') {
                selector.parent().show();
            } 
            // Hide queue selector for special clusters
            else if (key === 'queue') {
                selector.parent().toggle(!isSpecialCluster);
            } 
            // Hide other advanced options for special clusters
            else {
                selector.parent().toggle(!isSpecialCluster);
            }
        });

        // Reset advanced options and update form
        resetAdvancedOptions();
        if (!isSpecialCluster) {
            filterAccountPartitionOptions();
            setDefaultPartition(!initialSetup); // Set default partition for non-special clusters
            filterGPUOptions();
            partitionLimits(selectors.queue.val());
            toggleAdvancedOptions();
        }
        toggleCustomEnvironment(); // Always run this regardless of cluster type
    }

    // Run initial setup
    handleClusterSelection(true);

    // Add change event listeners
    selectors.cluster.on('change', () => handleClusterSelection(false));

    selectors.queue.on('change', function () {
        const selectedCluster = selectors.cluster.val();
        const isSpecialCluster = selectedCluster.includes('frisco') || selectedCluster.includes('bristlecone');

        if (!isSpecialCluster) {
            resetAdvancedOptions();
            partitionLimits($(this).val());
            filterGPUOptions();
            toggleGPU();
            setDefaultGPU();
            toggleCustomEnvironment();
            toggleAdvancedOptions();
        }
    });

    selectors.python.on('change', function() {
        toggleCustomEnvironment();
    });

    // Toggle functions and their associated inputs
    const toggleFunctionsAndInputs = {
        memtaskCheckbox: { toggle: toggleMemtask, input: selectors.memtask },
        gpuCheckbox: { toggle: toggleGPU, input: selectors.gpuType },
        nodelistCheckbox: { toggle: toggleNodelist, input: selectors.nodelist },
        addEnvCheckbox: { toggle: toggleAddEnv, input: selectors.addEnv },
        constraintCheckbox: { toggle: toggleConstraint, input: selectors.constraint },
        nodesCheckbox: { toggle: toggleNodes, input: selectors.numNodes }
    };

    // Attach change event handlers for toggle functions and inputs
    Object.entries(toggleFunctionsAndInputs).forEach(([checkboxKey, { toggle, input }]) => {
        selectors[checkboxKey].change(function() {
            const selectedCluster = selectors.cluster.val();
            const isSpecialCluster = selectedCluster.includes('frisco') || selectedCluster.includes('bristlecone');
            if (!isSpecialCluster) {
                toggle();
                toggleAdvancedOptions();
            }
        });
        input.on('input', function() {
            const selectedCluster = selectors.cluster.val();
            const isSpecialCluster = selectedCluster.includes('frisco') || selectedCluster.includes('bristlecone');
            if (!isSpecialCluster) {
                toggle();
                toggleAdvancedOptions();
            }
        });
    });

    // Special handling for GPU count
    selectors.gpuCount.on('input', function() {
        const selectedCluster = selectors.cluster.val();
        const isSpecialCluster = selectedCluster.includes('frisco') || selectedCluster.includes('bristlecone');
        if (!isSpecialCluster) {
            toggleGPU();
            toggleAdvancedOptions();
        }
    });

    // Special handling for advanced options
    selectors.advancedOptionsCheckbox.change(function() {
        const selectedCluster = selectors.cluster.val();
        const isSpecialCluster = selectedCluster.includes('frisco') || selectedCluster.includes('bristlecone');
        if (!isSpecialCluster) {
            toggleAdvancedOptions();
        }
    });
});
