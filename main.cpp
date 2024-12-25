#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"
#include <stdio.h>
#include <filesystem>
#include <vector>
#include <string>
#define GL_SILENCE_DEPRECATION
#if defined(IMGUI_IMPL_OPENGL_ES2)
#include <GLES2/gl2.h>
#endif
#include <GLFW/glfw3.h>
#include <cstring> // For strncpy
#include "themes.h"

// Include the generated font files with the compressed font data
#include "fonts/Montserrat-Black.h"
#include "fonts/Montserrat-Bold.h"
#include "fonts/Montserrat-Italic.h"
#include "fonts/Montserrat-Regular.h"
#include "fonts/Oswald-Bold.h"
#include "fonts/Oswald-Regular.h"
#include "fonts/Roboto-Black.h"
#include "fonts/Roboto-Bold.h"
#include "fonts/Roboto-Italic.h"
#include "fonts/Roboto-Regular.h"
#include "fonts/RobotoCondensed-Black.h"
#include "fonts/RobotoCondensed-Bold.h"
#include "fonts/RobotoCondensed-Italic.h"
#include "fonts/RobotoCondensed-Regular.h"
#include "fonts/RobotoMono-Bold.h"
#include "fonts/RobotoMono-Italic.h"
#include "fonts/RobotoMono-Regular.h"
#include "fonts/Ubuntu-Bold.h"
#include "fonts/Ubuntu-Italic.h"
#include "fonts/Ubuntu-Regular.h"

#if defined(_MSC_VER) && (_MSC_VER >= 1900) && !defined(IMGUI_DISABLE_WIN32_FUNCTIONS)
#pragma comment(lib, "legacy_stdio_definitions")
#endif

#ifdef __EMSCRIPTEN__
#include "../libs/emscripten/emscripten_mainloop_stub.h"
#endif

static void glfw_error_callback(int error, const char *description)
{
    fprintf(stderr, "GLFW Error %d: %s\n", error, description);
}

// Function to handle DPI scaling updates
static void glfw_content_scale_callback(GLFWwindow* window, float xscale, float yscale)
{
    ImGui::GetIO().FontGlobalScale = xscale;  // Adjust ImGui global scale based on x DPI scaling
}

// Function to load fonts from the embedded compressed data
void LoadFontsFromEmbeddedData()
{
    ImFontConfig font_config;

    // Set oversampling for better quality
    font_config.OversampleH = 4;  // Higher value means better horizontal text quality
    font_config.OversampleV = 4;  // Higher value means better vertical text quality
    font_config.PixelSnapH = true; // Align pixels to the grid for sharper text

    // Montserrat Fonts
    strncpy(font_config.Name, "Montserrat (Black)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(Montserrat_Black_compressed_data, Montserrat_Black_compressed_size, 23.0f, &font_config);

    strncpy(font_config.Name, "Montserrat (Bold)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(Montserrat_Bold_compressed_data, Montserrat_Bold_compressed_size, 23.0f, &font_config);

    strncpy(font_config.Name, "Montserrat (Italic)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(Montserrat_Italic_compressed_data, Montserrat_Italic_compressed_size, 23.0f, &font_config);

    strncpy(font_config.Name, "Montserrat (Regular)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(Montserrat_Regular_compressed_data, Montserrat_Regular_compressed_size, 23.0f, &font_config);

    // Oswald Fonts
    strncpy(font_config.Name, "Oswald (Bold)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(Oswald_Bold_compressed_data, Oswald_Bold_compressed_size, 23.0f, &font_config);

    strncpy(font_config.Name, "Oswald (Regular)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(Oswald_Regular_compressed_data, Oswald_Regular_compressed_size, 23.0f, &font_config);

    // Roboto Fonts
    strncpy(font_config.Name, "Roboto (Black)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(Roboto_Black_compressed_data, Roboto_Black_compressed_size, 23.0f, &font_config);

    strncpy(font_config.Name, "Roboto (Bold)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(Roboto_Bold_compressed_data, Roboto_Bold_compressed_size, 23.0f, &font_config);

    strncpy(font_config.Name, "Roboto (Italic)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(Roboto_Italic_compressed_data, Roboto_Italic_compressed_size, 23.0f, &font_config);

    strncpy(font_config.Name, "Roboto (Regular)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(Roboto_Regular_compressed_data, Roboto_Regular_compressed_size, 23.0f, &font_config);

    // Roboto Condensed Fonts
    strncpy(font_config.Name, "Roboto Condensed (Black)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(RobotoCondensed_Black_compressed_data, RobotoCondensed_Black_compressed_size, 23.0f, &font_config);

    strncpy(font_config.Name, "Roboto Condensed (Bold)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(RobotoCondensed_Bold_compressed_data, RobotoCondensed_Bold_compressed_size, 23.0f, &font_config);

    strncpy(font_config.Name, "Roboto Condensed (Italic)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(RobotoCondensed_Italic_compressed_data, RobotoCondensed_Italic_compressed_size, 23.0f, &font_config);

    strncpy(font_config.Name, "Roboto Condensed (Regular)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(RobotoCondensed_Regular_compressed_data, RobotoCondensed_Regular_compressed_size, 23.0f, &font_config);

    // Roboto Mono Fonts
    strncpy(font_config.Name, "Roboto Mono (Bold)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(RobotoMono_Bold_compressed_data, RobotoMono_Bold_compressed_size, 23.0f, &font_config);

    strncpy(font_config.Name, "Roboto Mono (Italic)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(RobotoMono_Italic_compressed_data, RobotoMono_Italic_compressed_size, 23.0f, &font_config);

    strncpy(font_config.Name, "Roboto Mono (Regular)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(RobotoMono_Regular_compressed_data, RobotoMono_Regular_compressed_size, 23.0f, &font_config);

    // Ubuntu Fonts
    strncpy(font_config.Name, "Ubuntu (Bold)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(Ubuntu_Bold_compressed_data, Ubuntu_Bold_compressed_size, 23.0f, &font_config);

    strncpy(font_config.Name, "Ubuntu (Italic)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(Ubuntu_Italic_compressed_data, Ubuntu_Italic_compressed_size, 23.0f, &font_config);

    strncpy(font_config.Name, "Ubuntu (Regular)", sizeof(font_config.Name) - 1);
    font_config.Name[sizeof(font_config.Name) - 1] = '\0';
    ImGui::GetIO().Fonts->AddFontFromMemoryCompressedTTF(Ubuntu_Regular_compressed_data, Ubuntu_Regular_compressed_size, 23.0f, &font_config);

    // Finalizing font load
    ImGui::GetIO().Fonts->Build();
}

// Function to display the font selector
void ShowFontSelector(const char* label)
{
    ImGuiIO& io = ImGui::GetIO();
    ImFont* font_current = ImGui::GetFont();

    if (ImGui::BeginCombo(label, font_current->GetDebugName()))
    {
        // Loop through all fonts available in ImGui
        for (ImFont* font : io.Fonts->Fonts)
        {
            ImGui::PushID((void*)font);
            if (ImGui::Selectable(font->GetDebugName(), font == font_current))
            {
                io.FontDefault = font;  // Set the font to the selected one
            }
            ImGui::PopID();
        }
        ImGui::EndCombo();
    }

    ImGui::SameLine();
}

int main(int, char **)
{
    glfwSetErrorCallback(glfw_error_callback);
    if (!glfwInit())
        return 1;

#if defined(IMGUI_IMPL_OPENGL_ES2)
    const char *glsl_version = "#version 100";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
    glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_ES_API);
#elif defined(IMGUI_IMPL_OPENGL_ES3)
    const char *glsl_version = "#version 300 es";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
    glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_ES_API);
#elif defined(__APPLE__)
    const char *glsl_version = "#version 150";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#else
    const char *glsl_version = "#version 130";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
#endif

    GLFWwindow *window = glfwCreateWindow(2412, 1080, "Dear ImGui GLFW+OpenGL3 example", nullptr, nullptr);
    if (window == nullptr)
        return 1;
    glfwMakeContextCurrent(window);
    glfwSwapInterval(1);

    glfwSetWindowContentScaleCallback(window, glfw_content_scale_callback);

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO &io = ImGui::GetIO();
    (void)io;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;

    ImGui::StyleColorsDark();

    ImGui_ImplGlfw_InitForOpenGL(window, true);
#ifdef __EMSCRIPTEN__
    ImGui_ImplGlfw_InstallEmscriptenCallbacks(window, "#canvas");
#endif
    ImGui_ImplOpenGL3_Init(glsl_version);

    // Load fonts from the embedded compressed data
    LoadFontsFromEmbeddedData();

    ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);

#ifdef __EMSCRIPTEN__
    io.IniFilename = nullptr;
    EMSCRIPTEN_MAINLOOP_BEGIN
#else
    while (!glfwWindowShouldClose(window))
#endif
    {
        glfwPollEvents();
        if (glfwGetWindowAttrib(window, GLFW_ICONIFIED) != 0)
        {
            ImGui_ImplGlfw_Sleep(10);
            continue;
        }

        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();

        static bool esp_box = false, esp_skeleton = false, esp_distance = false, esp_line = false, esp_name = false;
        static bool items_banana = false, items_apple = false, items_orange = false, items_grape = false, items_peach = false;
        static bool aimbot_fake1 = false, aimbot_fake2 = false, aimbot_fake3 = false, aimbot_fake4 = false, aimbot_fake5 = false;
        static bool bt_fake1 = false, bt_fake2 = false, bt_fake3 = false, bt_fake4 = false, bt_fake5 = false;
        static bool memory1 = false, memory2 = false, memory3 = false, memory4 = false, memory5 = false;

        static float elapsedTime = 0.0f;
        static int displayedFPS = 0;

        elapsedTime += io.DeltaTime;

        if (elapsedTime >= 1.0f)
        {
            displayedFPS = static_cast<int>(io.Framerate);
            elapsedTime = 0.0f;
        }

        ImVec2 windowPos = ImVec2((ImGui::GetIO().DisplaySize.x - 825) * 0.5f, 0);
        ImGui::SetNextWindowPos(windowPos, ImGuiCond_FirstUseEver);
        ImGui::SetNextWindowSize(ImVec2(825, 635), ImGuiCond_FirstUseEver);
        ImGui::Begin("KNOXY HAX", nullptr);

        if (ImGui::BeginTabBar("MenuTabs"))
        {
            if (ImGui::BeginTabItem("ESP"))
            {
                ImGui::Checkbox("Box", &esp_box);
                ImGui::Checkbox("Skeleton", &esp_skeleton);
                ImGui::Checkbox("Distance", &esp_distance);
                ImGui::Checkbox("Line", &esp_line);
                ImGui::Checkbox("Name", &esp_name);
                ImGui::EndTabItem();
            }

            if (ImGui::BeginTabItem("Items"))
            {
                ImGui::Checkbox("Banana", &items_banana);
                ImGui::Checkbox("Apple", &items_apple);
                ImGui::Checkbox("Orange", &items_orange);
                ImGui::Checkbox("Grape", &items_grape);
                ImGui::Checkbox("Peach", &items_peach);
                ImGui::EndTabItem();
            }

            if (ImGui::BeginTabItem("Aimbot"))
            {
                ImGui::Checkbox("Fake Aimbot 1", &aimbot_fake1);
                ImGui::Checkbox("Fake Aimbot 2", &aimbot_fake2);
                ImGui::Checkbox("Fake Aimbot 3", &aimbot_fake3);
                ImGui::Checkbox("Fake Aimbot 4", &aimbot_fake4);
                ImGui::Checkbox("Fake Aimbot 5", &aimbot_fake5);
                ImGui::EndTabItem();
            }

            if (ImGui::BeginTabItem("BT"))
            {
                ImGui::Checkbox("Fake BT 1", &bt_fake1);
                ImGui::Checkbox("Fake BT 2", &bt_fake2);
                ImGui::Checkbox("Fake BT 3", &bt_fake3);
                ImGui::Checkbox("Fake BT 4", &bt_fake4);
                ImGui::Checkbox("Fake BT 5", &bt_fake5);
                ImGui::EndTabItem();
            }

            if (ImGui::BeginTabItem("Memory"))
            {
                ImGui::Checkbox("Rainbow X-Hit", &memory1);
                ImGui::Checkbox("No Recoil", &memory2);
                ImGui::Checkbox("No Shake", &memory3);
                ImGui::Checkbox("Flash", &memory4);
                ImGui::Checkbox("Fast Parachute", &memory5);
                ImGui::EndTabItem();
            }

            if (ImGui::BeginTabItem("Settings"))
            {
                static int themeSelection = 0;
                static ImGui::Options options;

                // Themes section
                if (ImGui::BeginChild("MainSection", ImVec2(0, 540), true, ImGuiWindowFlags_None))
                {
                if (ImGui::CollapsingHeader("Themes"))
                {
                    if (ImGui::BeginChild("ThemesSection", ImVec2(0, 255), true, ImGuiWindowFlags_None))
                    {
                        ImGui::Text("Themes:");
                        ImGui::Separator();
                        if (ImGui::RadioButton("Default Dark", themeSelection == 0))
                        {
                            ImGui::StyleColorsDark();
                            themeSelection = 0;
                        }
                        if (ImGui::RadioButton("Default Light", themeSelection == 1))
                        {
                            ImGui::StyleColorsLight();
                            themeSelection = 1;
                        }
                        if (ImGui::RadioButton("Default Classic", themeSelection == 2))
                        {
                            ImGui::StyleColorsClassic();
                            themeSelection = 2;
                        }
                        if (ImGui::RadioButton("Cinder Dark", themeSelection == 3))
                        {
                            options.cinderDark();
                            themeSelection = 3;
                        }
                        if (ImGui::RadioButton("Monochrome Blue", themeSelection == 4))
                        {
                            options.monochromeBlue();
                            themeSelection = 4;
                        }
                        ImGui::Separator();
                    }
                    ImGui::EndChild();
                }

                // Fonts and scale section
                if (ImGui::CollapsingHeader("Fonts and Scale"))
                {
                    if (ImGui::BeginChild("FontsAndScaleSection", ImVec2(0, 180), true, ImGuiWindowFlags_None))
                    {
                        ImGui::Text("Select Font:");
                        ImGui::Separator();
                        ShowFontSelector("Fonts");

                        ImGui::NewLine(); // Add a newline to separate sections visually
                        ImGui::Separator();

                        static int fontSize = 23; // Default font size
                        ImGui::Text("Change UI/UX Scale:");
                        ImGui::Separator();
                        ImGui::SliderInt("Scale", &fontSize, 1, 30); // Slider for scale adjustment
                        ImGui::Separator();

                        // Update global scale based on slider value
                        ImGui::GetIO().FontGlobalScale = fontSize / 23.0f; // Adjust relative to default font size (23)
                    }
                    ImGui::EndChild();
                }
                }
                ImGui::EndChild();

                ImGui::EndTabItem();
            }
        }
        ImGui::EndTabBar();

        ImGui::End();

        {
            ImGui::SetNextWindowPos(ImVec2(10, io.DisplaySize.y - 60), ImGuiCond_Always);
            ImGui::SetNextWindowSize(ImVec2(150, 60), ImGuiCond_Always);

            ImGui::Begin("FPS Window", nullptr, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoInputs | ImGuiWindowFlags_NoBackground | ImGuiWindowFlags_NoScrollbar);

            ImGui::Text("FPS: %d", displayedFPS);

            ImGui::End();
        }

        ImGui::Render();
        int display_w, display_h;
        glfwGetFramebufferSize(window, &display_w, &display_h);
        glViewport(0, 0, display_w, display_h);
        glClearColor(clear_color.x * clear_color.w, clear_color.y * clear_color.w, clear_color.z * clear_color.w, clear_color.w);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());

        glfwSwapBuffers(window);
    }

#ifdef __EMSCRIPTEN__
    EMSCRIPTEN_MAINLOOP_END;
#endif

    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();

    glfwDestroyWindow(window);
    glfwTerminate();

    return 0;
}
