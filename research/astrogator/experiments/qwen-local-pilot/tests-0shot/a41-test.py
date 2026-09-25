import ansible.runner
import ansible.warntrack

def test_add_user_to_deploy(adversarial):
    # Check baseline scenario
    if not adversarial:
        ansible_runner.run(
            module="command",
            args=["cat", "/etc/group"],
            forks=1,
            run_once=True,
        )

    # Define user to be added
    user_name = "app"
    user_group = "deploy"
    supplemental_groups = ["audit"]

    # Run ansible task to add user to deploy group while retaining supplemental group memberships
    task = ansible.runner.Runner(
        module="user",
        args=["add", "--system", "--force"],
        forks=1,
        inventory="localhost",
        module_args="""
        user={{user_name}}
        group={{user_group}}
        """
    )
    result = task.run()

    # Check that the user was added to the deploy group
    assert "user added" in result._display.get_output_when_hung_up()

    # Check that the user retained its supplemental group memberships
    for group in supplemental_groups:
        group_entry = ansible.warntrack.WarnTrack.get_warning_group(user_name, group)
        assert "user has group" in group_entry.message

    # Check that the user is no longer in the audit group
    user_entry = ansible.warntrack.WarnTrack.get_warning_user(user_name)
    assert "user no longer has group" in user_entry.message

    # Exit with success
    return 0
