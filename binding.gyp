{
  'targets': [
    {
      'target_name': 'addon',
      'variables': {
        'rust_target_dir': ['<(module_root_dir)/native/Rust/pi_est_c_wrapper/target'],
        'manifest': ['<(module_root_dir)/native/Rust/pi_est_c_wrapper/Cargo.toml']
      },
      'sources': [
        'native/addon.cc',
      ],
      'include_dirs': ['<!(node -e "require(\'nan\')")'],
      'conditions': [
        ['OS=="linux"', {
          'libraries': [
            '<(rust_target_dir)/release/libpi_est_c_wrapper.so'
          ],
          'actions': [{
            'action_name': 'build_rust_linux',
            'message': 'Building Rust (Release)',
            'inputs': ['<(manifest)'],
            'outputs': ['<(rust_target_dir)/release/libpi_est_c_wrapper.so'],
            'action': ['cargo', 'build', '--release', '--manifest-path', '<(manifest)']
          }]
        }],
        ['OS=="mac"', {
          'libraries': [
            '<(rust_target_dir)/release/libpi_est_c_wrapper.dylib'
          ],
          'actions': [{
            'action_name': 'build_rust_mac',
            'message': 'Building Rust (Release)',
            'inputs': ['<(manifest)'],
            'outputs': ['<(rust_target_dir)/release/libpi_est_c_wrapper.dylib'],
            'action': ['cargo', 'build', '--release', '--manifest-path', '<(manifest)']
          }]
        }]
      ]
    }
  ]
}
