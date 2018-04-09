namespace: demo
flow:
  name: CreateVM
  inputs:
    - host: 10.0.46.10
    - username: "Capa1\\1289-capa1user"
    - password: Automation123
    - DataCenter: Capa1 Datacenter
    - image: Ubuntu
    - folder: Students/Claudios
    - prefix_list: '1-,2-,3-'
  workflow:
    - uuid:
        do:
          io.cloudslang.demo.uuid:
            - input_0: null
        publish:
          - uuid: '${"cla-"+uuid}'
        navigate:
          - SUCCESS: substring
    - substring:
        do:
          io.cloudslang.base.strings.substring:
            - origin_string: '${uuid}'
            - end_index: '7'
        publish:
          - id: '${new_string}'
        navigate:
          - SUCCESS: clone_vm
          - FAILURE: on_failure
    - clone_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.vm.clone_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_source_identifier: name
              - vm_source: '${image}'
              - datacenter: '${DataCenter}'
              - vm_name: '${prefix+id}'
              - vm_folder: '${folder}'
              - mark_as_template: 'false'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: power_on_vm
          - FAILURE: on_failure
    - power_on_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.power_on_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: '${name}'
              - vm_name: '${prefix+id}'
              - trust_all_roots: '${true}'
              - x_509_hostname_verifier: '${allow_all}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      uuid:
        x: 33
        y: 114
      substring:
        x: 261
        y: 45
      clone_vm:
        x: 504
        y: 65
      power_on_vm:
        x: 194
        y: 221
        navigate:
          06848ae8-4af9-7106-1718-60c8bf625042:
            targetId: 92809c18-8adb-2f2d-077e-3c54f7207ee0
            port: SUCCESS
    results:
      SUCCESS:
        92809c18-8adb-2f2d-077e-3c54f7207ee0:
          x: 413
          y: 272
