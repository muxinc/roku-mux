package main

// TODO do the tests actually run? did they ever? what's missing?

import (
	"archive/zip"
	"bufio"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

import "github.com/bmatcuk/doublestar/v4"

var firstWordsByMin = map[string]string{
	"a": "property", // account
	"b": "beacon",
	"d": "ad",
	"e": "event",
	"f": "experiment", // nothing better to use...
	"m": "mux",
	"p": "player",
	"r": "retry", // placeholder for beacons adding retry counts
	"s": "session",
	"t": "timestamp",
	"u": "viewer", // user
	"v": "video",
	"w": "page", // web page
	"x": "view",
	"y": "sub", // cause nowhere else to fit it
  }
  
  var expectedWordsByMin = map[string]string{
	"ad": "ad",
	"ag": "aggregate",
	"ap": "api",
	"al": "application",
	"ar": "architecture",
	"as": "asset",
	"au": "autoplay",
	"br": "break",
	"cd": "code",
	"cg": "category",
	"cn": "config",
	"co": "count",
	"cp": "complete",
	"ct": "content",
	"cu": "current",
	"dg": "downscaling",
	"dm": "domain",
	"dn": "cdn",
	"do": "downscale",
	"du": "duration",
	"dv": "device",
	"ec": "encoding",
	"en": "end",
	"eg": "engine",
	"em": "embed",
	"er": "error",
	"ev": "events",
	"ex": "expires",
	"fi": "first",
	"fm": "family",
	"ft": "format",
	"fq": "frequency",
	"fr": "frame",
	"fs": "fullscreen",
	"ho": "host",
	"hn": "hostname",
	"ht": "height",
	"id": "id",
	"ii": "init",
	"in": "instance",
	"ip": "ip",
	"is": "is",
	"ke": "key",
	"la": "language",
	"li": "live",
	"lo": "load",
	"ma": "max",
	"me": "message",
	"mi": "mime",
	"ml": "midroll",
	"mn": "manufacturer",
	"mo": "model",
	"mx": "mux",
	"nm": "name",
	"no": "number",
	"on": "on",
	"os": "os",
	"pa": "paused",
	"pb": "playback",
	"pd": "producer",
	"pe": "percentage",
	"pf": "played",
	"ph": "playhead",
	"pi": "plugin",
	"pl": "preroll",
	"po": "poster",
	"pr": "preload",
	"py": "property",
	"ra": "rate",
	"rd": "requested",
	"re": "rebuffer",
	"ro": "ratio",
	"rq": "request",
	"rs": "requests",
	"sa": "sample",
	"se": "session",
	"sk": "seek",
	"sm": "stream",
	"so": "source",
	"sq": "sequence",
	"sr": "series",
	"st": "start",
	"su": "startup",
	"sv": "server",
	"sw": "software",
	"ta": "tag",
	"tc": "tech",
	"ti": "time",
	"tl": "total",
	"to": "to",
	"tt": "title",
	"ty": "type",
	"ug": "upscaling",
	"up": "upscale",
	"ur": "url",
	"us": "user",
	"va": "variant",
	"vd": "viewed",
	"vi": "video",
	"ve": "version",
	"vw": "view",
	"vr": "viewer",
	"wd": "width",
	"wa": "watch",
	"wt": "waiting",
  }

var env_roku_ip = "192.168.2.233"
var env_roku_user = "rokudev"
var env_roku_pass = "rokudev"

const out_dir_name = "out"
const app_name = "mux"
const sampleAppType = "something"
const build_dir_name = "build"

const appTypeRecycleVideo = "recycleVideo"

var NotImplementedError = errors.New("Not implemented")

type task struct {
	depends []string
	main func() error
}

type runner struct {
	tasks map[string]task 
	done map[string] bool
}

func NewRunner() *runner {
	return &runner{
		tasks: make(map[string]task),
		done: make(map[string] bool),
	}
}

func (r *runner) AddTask(name string, t task) {
	r.tasks[name] = t
}

func run(cmd string, args...string) (string, error) {
	log.Println("exec:", cmd, strings.Join(args, " "))

	c := exec.Command(cmd, args...)

	var outbuf, errbuf strings.Builder
	c.Stdout = &outbuf
	c.Stderr = &errbuf

	err := c.Run()

	if err != nil {
		log.Println(errbuf.String())
	}

	out := outbuf.String()
	if len(out) > 0 {
		log.Println(out)
	}

	return out, err
}

func zipFiles(basedir string, outpath string, patterns... string) error {
	log.Println("zipFiles")
	log.Println("Creating zip file at", outpath)

	os.MkdirAll(filepath.Dir(outpath), 0777)

	zipfile, err := os.Create(outpath)
	if err != nil {
		return err
	}
	defer zipfile.Close()

	zipWriter := zip.NewWriter(zipfile)
	defer zipWriter.Close()

	for _, p := range(patterns) {
		log.Println("Compressing pattern", p)

		fsys := os.DirFS("./")
		matches, err := doublestar.Glob(fsys, p)
		if err != nil {
			return err
		}

		for _, m := range(matches) {
			name := m[len(basedir):]
			// Roku may not like leading slash
			if len(name) > 0 && name[0] == '/' {
				name = name[1:]
			}

			log.Println("Compressing file", m, "base", basedir, "to", name)
			f, err := os.Open(m)
			if err != nil {
				return err
			}
			defer f.Close()

			info, err := f.Stat()
			if err != nil {
				return err
			}

			if !info.IsDir() {
				header, err := zip.FileInfoHeader(info)
				if err != nil {
					return err
				}

				header.Name = name
				if strings.HasSuffix(name, ".png") {
					// Do not compress PNGs
					header.Method = zip.Store
				} else {
					header.Method = zip.Deflate
				}

				w, err := zipWriter.CreateHeader(header)
				if err != nil {
					return err
				}

				_, err = io.Copy(w, f)
				if err != nil {
					return err
				}
			}
		}
	}

	return nil
}

func copyFiles(basedir string, outdirpath string, patterns... string) error {
	log.Println("copyFiles")

	for _, p := range(patterns) {
		fsys := os.DirFS("./")
		matches, err := doublestar.Glob(fsys, p)
		if err != nil {
			return err
		}

		for _, m := range(matches) {
			src, err := os.Open(m)
			if err != nil {
				return err
			}
			defer src.Close()

			destPath := filepath.Join(outdirpath, m[len(basedir):])
			os.MkdirAll(filepath.Dir(destPath), 0777)

			info, _ := os.Stat(m)
			if !info.IsDir() {
				dest, err := os.Create(destPath)
				if err != nil {
					return err
				}
				defer dest.Close()
	
				n, err := io.Copy(dest, src)
				if err != nil {
					return err
				}
	
				if n == 0 {
					return errors.New("No bytes copied")
				}
			}
		}
	}

	return nil
}

func deleteDirectory(dirpath string) error {
	log.Println("deleteDirectory")
	return os.RemoveAll(dirpath)
}

func loadFileAsString(filepath string) (string, error) {
	log.Println("loadFileAsString")

	d, err := ioutil.ReadFile(filepath)
	if err != nil {
		return "", err
	}

	return string(d), nil
}

func saveStringToFile(value string, filepath string) error {
	log.Println("saveStringToFile")

	f, err := os.Create(filepath)
	if err != nil {
		return err
	}
	defer f.Close()

	_, err = io.Copy(f, strings.NewReader(value))
	if err != nil {
		return err
	}

	return nil
}

func replace(input string, mappings map[string]string) string {
	log.Println("replace")

	output := input

	for a, b := range(mappings) {
		output = strings.ReplaceAll(output, a, b)
	}

	return output
}

func (r *runner) Run(taskname string) error {
	if r.done[taskname] {
		// Skip the already done task (a bizarre possible gulp-ism)
		return nil
	} else {
		r.done[taskname] = true
	}

	log.Println("[" + taskname + "]")
	// defer log.Println(taskname, "ended")

	t, ok := r.tasks[taskname]
	if !ok {
		return errors.New("Task not found: "+taskname)
	}

	for _, d := range(t.depends) {
		err := r.Run(d)
		if err != nil {
			log.Println(err.Error())
			return err
		}
	}

	if t.main != nil{
		err := t.main()
		if err != nil {
			log.Println(err.Error())
			return err
		}
	}

	return nil
}

func rokutasks(r *runner) {
	r.AddTask("clean.build", task{
		main: func() error {
			return deleteDirectory("build")
		},
	})

	r.AddTask("clean.out", task{
		main: func() error {
			return deleteDirectory("out")
		},
	})

	r.AddTask("clean", task{
		depends: []string{"clean.build", "clean.out"},
	})

	r.AddTask("install", task{
		depends: []string{"closeApp", "clean", "build_sample_app", "build_components", "package", "deploy"}, 
	})

	r.AddTask("deploy", task{
		depends: []string{"closeApp", "clean", "build_sample_app","build_components", "package"},
		main: func() error {
			log.Printf("Deploying to device IP: %s (%s | %s)\n", env_roku_ip, env_roku_user, env_roku_pass)
			
			_, err := run("curl",
				"--user", env_roku_user + ":" + env_roku_pass,
				"--digest", "--show-error", 
				"-F", "mysubmit=Install",
				"-F", "archive=@\"" + out_dir_name + "/" + app_name+ ".zip\"", 
				"--output", "/tmp/dev_server_out",
				"--write-out", "%{response_code}", "http://" + env_roku_ip + "/plugin_install")
			return err
		},
	})

	r.AddTask("build_sample_app", task{
		depends: []string{"clean"},
		main: func() error {
			return copyFiles("sampleapp_source", build_dir_name, "sampleapp_source/source/**", "sampleapp_source/components/**", "sampleapp_source/libs/**","sampleapp_source/images/**", "sampleapp_source/feed/**", "sampleapp_source/manifest")
		},
	})

	r.AddTask("build_components", task{
		depends: []string{"clean", "build_sample_app"},
		main: func() error {
			if sampleAppType == appTypeRecycleVideo {
				return copyFiles("sampleapp_source/components_recycled", build_dir_name, "sampleapp_source/components_recycled/**")
			} else {
				return copyFiles("sampleapp_source/components_reset", build_dir_name, "sampleapp_source/components_reset/**")
			}
			return nil
		},
	})

	r.AddTask("build_src", task{
		depends: []string{"clean", "build_sample_app", "build_components"},
		main: func() error {
			return copyFiles("src", build_dir_name + "/libs", "src/**")
		},
	})

	r.AddTask("deploy_test", task{
		depends: []string{"closeApp", "package_test"},
		main: func() error {
			_, err := run("curl", "--user", env_roku_user+":"+env_roku_pass, "--digest", "--show-error", 
				"-F", "mysubmit=Install", 
				"-F", "archive=@\"" + out_dir_name + "/" + app_name + "-tests.zip\"",
				"--output", "/tmp/dev_server_out",
				"--write-out", "%{http_code}",
				"http://" +env_roku_ip + "/plugin_install")
			return err
		},
	})

	r.AddTask("test", task{
		depends: []string{}, 
		main: func() error {
			_, err := run("curl", "-d", "", "http://"+env_roku_ip+":8060/launch/dev?RunTests=true")
			return err
		},
	})

	r.AddTask("lint", task{
		depends: []string{"build_src"},
		main: func() error {
			// This relies on the rokucommunity/bslint being installed
			// Should be installable via "npm install" in roku-mux root
			_, err := run("npx", "bslint", "--rootDir", "build")
			return err
		},
	})

	r.AddTask("build_test_source", task{
		depends: []string{"build_sample_app", "clean"},
		main: func() error {
			return copyFiles("test/source_tests/", build_dir_name, "test/source_tests/source/**")
		},
	})

	// r.AddTask("build_test_replace_main", task{
	// 	depends: []string{"build_sample_app", "clean"},
	// 	main: func() error {
	// 		return copyFiles("test/source_tests/source", build_dir_name + "/source", "test/source_tests/source/main.brs")
	// 	},
	// })

	r.AddTask("build_test_components", task{
		depends: []string{"build_sample_app", "clean"},
		main: func() error {
			return copyFiles("", build_dir_name, "test/component_tests/**")
		},
	})

	r.AddTask("add_test_framework", task{
		depends: []string{"clean", "build_sample_app", "build_test_source"},
		main: func() error {
			return copyFiles("test", build_dir_name + "/source", "test/testFramework/*")
		},
	})

	r.AddTask("add_mux_library_to_test", task{
		depends: []string{"clean", "build_sample_app", "build_test_source"},
		main: func() error {
			return copyFiles("src", build_dir_name + "/libs", "src/mux-analytics.brs")
		},
	})

	r.AddTask("package_test", task{
		depends: []string{"build_sample_app", "build_components", "build_test_components", "build_test_source", "add_test_framework", "add_mux_library_to_test"},
		main: func() error {
			return zipFiles("build", "out/"+app_name+"-tests.zip", "build/**")
		},
	})

	r.AddTask("package", task{
		depends: []string{"build_sample_app", "build_components", "build_src", "clean"},
		main: func() error {
			return zipFiles("build", "out/"+app_name+".zip", "build/**")
		},
	})

	r.AddTask("closeApp", task{
		main: func() error {
			_, err := run("curl", "-d", "''", "http://" + env_roku_ip + ":8060/keypress/home")
			return err
		},
	})

	r.AddTask("replace", task{
		depends: []string{"build_sample_app", "clean"},
		main: func() error {
			mappings := make(map[string]string)

			mappings["mux_viewer_id"] = "mvrid"
			mappings["player_software_name"] = "pswnm"
			mappings["player_software_version"] = "pswve"
			mappings["player_model_number"] = "pmono"
			mappings["player_mux_plugin_name"] = "pmxpinm"
			mappings["player_mux_plugin_version"] = "pmxpive"
			mappings["player_language_code"] = "placd"
			mappings["player_width"] = "pwd"
			mappings["player_height"] = "pht"
			mappings["player_error_code"] = "percd"
			mappings["player_error_message"] = "perme"
			mappings["player_is_fullscreen"] = "pisfs"
			mappings["player_is_paused"] = "pispa"
			mappings["video_source_url"] = "vsour"
			mappings["video_source_hostname"] = "vsohn"
			mappings["video_source_domain"] = "vsodm"
			mappings["video_source_format"] = "vsoft"
			mappings["video_source_duration"] = "vsodu"
			mappings["video_source_is_live"] = "vsoisli"
			mappings["video_source_width"] = "vsowd"
			mappings["video_source_height"] = "vsoht"
			mappings["video_title"] = "vtt"
			mappings["video_series"] = "vsr"
			mappings["video_producer"] = "vpd"
			mappings["video_content_type"] = "vctty"
			mappings["video_id"] = "vid"
			mappings["viewer_user_id"] = "uusid"
			mappings["view_time_to_first_frame"] = "xtitofifr"

			in, err := loadFileAsString("build/libs/mux-analytics.brs")
			if err != nil {
				return err
			}

			modified := replace(in, mappings)

			return saveStringToFile(modified, "build/libs/mux-analytics.brs")
		},
	})
}

func loadProperties(path string) map[string]string {
	props := make(map[string]string)

	f, err := os.Open(path)
    if err != nil {
		log.Println("No properties file at", path)
        return props
    }
    defer f.Close()

    scanner := bufio.NewScanner(f)
	scanner.Split(bufio.ScanLines)

	for scanner.Scan() {
		line := scanner.Text()
		if !strings.HasPrefix(line, "#") {
			index := strings.Index(line, "=")
			if index >= 0 {
				props[line[:index]] = line[index + 1:]
			}
		}
	}

    return props
}

func fromEnvVarOrProperties(key string, props map[string]string) string {
	v := os.Getenv(key)
	_, exists := props[key]
	if exists {
		v = props[key]
	}

	if v == "" {
		log.Fatal("Must set environment variable or property (in local.properties) "+key)
	}

	return v
}

func main() {
	fmt.Println("Roku test runner - port of the npm gulp that appears to be broken")

	r := NewRunner()

	rokutasks(r)

	if len(os.Args) != 2 {
		fmt.Println("USAGE: test_runner [taskname]")
		return
	}

	props := loadProperties("local.properties")

	env_roku_ip = fromEnvVarOrProperties("ROKU_IP", props)
	env_roku_user = fromEnvVarOrProperties("ROKU_USER", props)
	env_roku_pass = fromEnvVarOrProperties("ROKU_PASSWORD", props)

	err := r.Run(os.Args[1])

	if err != nil {
		log.Fatal("ERROR")
	}
}