# Proposal: Active Process Store

This is a storage system used for storing active processes and code inside separate context processes.

## Overview

The process (e.g a communication service, server, normal executable and more) is stored in a context which is used to store the process in the "database". When the process is needed, it is cloned and then started, which puts the process in action and then does its needed job. Once done, the process prototype/clone can be deleted or removed when done/