add_executable(qomodoro main.cpp resources.qrc)
target_link_libraries(qomodoro Qt5::Quick Qt5::Qml Qt5::Gui Qt5::QuickControls2 Qt5::Widgets KF5::Kirigami2 KF5::I18n)
install(TARGETS qomodoro ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})
