---
slug: hcp-boundary
id: hl1g9vemnccc
type: challenge
title: HCP Boundary
notes:
- type: text
  contents: |-
    <center>
    Clue #2
    <br><br>
    <hr>
    <br> <br>
    For the next two digits, find the flashlight.
    <br> <br><br>
    <hr>
    </center>
tabs:
- id: hgn6zad3asdx
  title: Terminal
  type: terminal
  hostname: tools
  workdir: /
- id: daujdbvpk9ju
  title: Code
  type: code
  hostname: tools
  path: /solutions
- id: clo3ofh0jykd
  title: Boundary
  type: service
  hostname: tools
  path: /vnc_lite.html
  port: 6080
difficulty: ""
enhanced_loading: null
---
## Tasks
After patching the VM estate, auditors have requested you to provide proof of patch from a randomly selected VM. They would like to see a log file for an internal piece of software called `patchify` to confirm the version installed and running is version `10.2.7`.

Boundary is a remote access solution that provides secure identity-based remote access to infrastructure and systems on private networks. Boundary desktop is a GUI client application that enables users to start sessions to systems and infrastructure that they are authorized to access.

**Using the Boundary desktop client:**
- Log in to Boundary desktop client
	- The Desktop client is on the Desktop of the Boundary tab
	- The crededntials, cluster URL and scope are in a file on the desktop called `boundary-creds`
- Use Boundary to start a session to `payments-vm`
- Run the following command within the Boundary target
	- `cat /patchify/logs.txt`

## Submission
Use the `Solutions` tab to submit the proof of patch for this VM:
- Find the codename in the log file
- Write the codename in a file named: `/solutions/data.json`
- Click check to verify the patch
