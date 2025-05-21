// A generated module for HelloDagger functions
//
// This module has been generated via dagger init and serves as a reference to
// basic module structure as you get started with Dagger.
//
// Two functions have been pre-created. You can modify, delete, or add to them,
// as needed. They demonstrate usage of arguments and return types using simple
// echo and grep commands. The functions can be called from the dagger CLI or
// from one of the SDKs.
//
// The first line in this comment block is a short description line and the
// rest is a long description with more detail on the module's purpose or usage,
// if appropriate. All modules should have a short description.

package main

import (
	"fmt"

	"dagger/hello-dagger/internal/dagger"
)

type HelloDagger struct{}

// CleanGitHistory runs the clean_git_history tool in a container
func (m *HelloDagger) CleanGitHistory(
	// +defaultPath="/"
	source *dagger.Directory,
) *dagger.Container {
	version := "v1.0.2"
	downloadURL := fmt.Sprintf("https://github.com/DeveloperC286/clean_git_history/releases/download/%s/x86_64-unknown-linux-musl.tar.gz", version)

	return dag.Container().
		From("rust:1.87.0-alpine3.21@sha256:fa7c28576553c431224a85c897c38f3a6443bd831be37061ab3560d9e797dc82").
		WithExec([]string{"wget", "-O", "-", downloadURL}).
		WithExec([]string{"tar", "xz", "--directory", "/usr/bin/"}).
		WithWorkdir("/clean_git_history").
		WithMountedDirectory("/clean_git_history/.git", dag.CurrentModule().Source().Directory(".git")).
		Directory("./.git").
		WithExec([]string{"clean_git_history", "origin/HEAD"})
}
