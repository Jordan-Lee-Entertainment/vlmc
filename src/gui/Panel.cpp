#include <QWidget>
#include <QVBoxLayout>
#include <QButtonGroup>
#include <QLabel>
#include <QIcon>
#include <QString>
#include <QToolButton>
#include <QSizePolicy>
#include <QSize>

//DEBUG
#include <QtDebug>
//~DEBUG

#include "Panel.h"

const int   Panel::M_ICON_HEIGHT = 64;

Panel::Panel( QWidget* parent )
    : QWidget( parent ),
    m_layout( 0 ),
    m_buttons( 0 ),
    m_firstButton( 0 ),
    m_firstButtonNb( 0 )
{
    m_layout = new QVBoxLayout( this );
    m_buttons = new QButtonGroup( this );

    m_buttons->setExclusive( true );
    m_layout->setMargin( 0 );
    m_layout->setSpacing( 1 );

    QObject::connect( m_buttons,
                      SIGNAL( buttonClicked( int ) ),
                      this,
                      SLOT( switchPanel( int ) ) );
    setSizePolicy( QSizePolicy::Expanding,
                           QSizePolicy::Expanding );
    setLayout( m_layout );
}

Panel::~Panel()
{
    delete m_layout;
    delete m_buttons;
}

void    Panel::addButton( const QString& label,
                          const QString& iconPath,
                          int number)
{
    QToolButton*    button = new QToolButton( this );

    button->setText( label );
    button->setIcon( QIcon( iconPath ) );
    button->setAutoRaise( true );
    button->setCheckable( true );
    button->setIconSize( QSize( Panel::M_ICON_HEIGHT,
                                Panel::M_ICON_HEIGHT) );
    button->setToolButtonStyle( Qt::ToolButtonTextUnderIcon  );
    button->resize( Panel::M_ICON_HEIGHT + 6,
                    Panel::M_ICON_HEIGHT + 6 );

    button->setSizePolicy( QSizePolicy::Expanding,
                           QSizePolicy::Expanding );
    if ( m_firstButton == 0 )
    {
        button->setChecked( true );
        m_firstButton = button;
        m_firstButtonNb = number;
    }
    m_buttons->addButton( button, number );
    m_layout->addWidget( button );
}

void    Panel::show()
{
    if ( !m_firstButton->isChecked() )
    {
        m_firstButton->setChecked( true );
        emit changePanel( m_firstButtonNb );
    }
    QWidget::show();
}

void    Panel::switchPanel( int panel )
{
    emit changePanel( panel );
}
